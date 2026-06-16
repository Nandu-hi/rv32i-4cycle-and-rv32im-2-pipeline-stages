/*
    BitNetMCU inference functions
    @cpldcpu April 2024

    Performs inference on fully connected layer on a very resource constrained MCU.
    1,2,4 bit weights are supported.

*/

#include <stdint.h>
#include <stdio.h>
#include "BitNetMCU_inference.h"

/**
 * @brief Applies a ReLU activation function to an array of integers and normalizes the result to 8-bit integers.
 *
 * @param input Pointer to the input array of 32-bit integers.
 * @param output Pointer to the output array of 8-bit integers.
 * @param n_input The number of elements in the input array.
 * @return The position of maximum value found in the input array before applying the ReLU activation.
 */

uint32_t ReLUNorm(int32_t *input, int8_t *output, uint32_t n_input) {
    int32_t max_val = -INT32_MAX;
    int32_t max_pos = 255;
    uint32_t scale;
    uint32_t shift;
    int32_t rounding;
    int32_t tmp;

    // Find the maximum value in the input array
    for (uint32_t i = 0; i < n_input; i++) {
        if (input[i] > max_val) {
            max_val = input[i];
            max_pos = i;
        }
    }

    // Normalization
    // Dynamic shift according to max value in the input array
    scale=max_val>>7;  // define max range, all bits above 7 will be shifted down
    shift=0;

    while (scale>0) {
        shift++;
        scale>>=1;
    }

    // impact of rounding is almost negligible (+0.03% in eval accuracy)
    // But rounding affects mismatch to python inference engine
    rounding   = (1 << (shift))>>1;

    // Apply ReLU activation and normalize to 8-bit
    for (uint32_t i = 0; i < n_input; i++) {
        // Apply ReLU activation
        if (input[i] < 0) {
            output[i] = 0;
        } else {
            tmp=(input[i] + rounding) >> shift;

            // clipping needed to catch overflow from rounding
            if (tmp > 127) {
                output[i] = 127;
            } else {
            output[i] = tmp;
            }
        }
    }
    print_str("---");
    return max_pos;
}

/**
 * @brief Processes a fully connected layer in a neural network.
 *
 * This function processes a fully connected layer in a neural network by performing
 * the dot product of the input activations and weights, and stores the result in the output array.
 *
 * @param activations Pointer to the input activations of the layer.
 * @param weights Pointer to the weights of the layer.
 * @param bits_per_weight The number of bits per weight.
 * @param n_input The number of input neurons.
 * @param n_output The number of output neurons.
 * @param output Pointer to the output array where the result of the layer is stored.
 */

 int32_t multiply_soft(int32_t a, int32_t b) {
    int32_t res = 0;
    
    // Handle signs: convert to absolute for calculation
    int negate = (a < 0) ^ (b < 0);
    uint32_t x = (a < 0) ? -a : a;
    uint32_t y = (b < 0) ? -b : b;

    while (y > 0) {
        if (y & 1) res += x; // If bit is 1, add
        x <<= 1;             // Shift multiplicand
        y >>= 1;             // Shift multiplier
    }
    
    return negate ? -res : res;
}


void processfclayer( int8_t *activations,  const int8_t *weights, int32_t bits_per_weight, uint32_t n_input, uint32_t n_output, int32_t *output)
{
   const int8_t *weightidx = weights;

    for (uint32_t i = 0; i < n_output; i++) {
        int8_t *activations_idx = activations;
        int16_t sum = 0;

            for (uint32_t k = 0; k < n_input; k+=16) {
                for (uint32_t j = 0; j < 16; j++) {
                    int8_t weightChunk = *weightidx++;
                    int8_t in=*activations_idx++;
                    sum = sum + multiply_soft(weightChunk,in) ;
                }
            }   
        output[i] = sum;
        print_str("."); 
    }
}


#ifndef MODEL_FCMNIST

/**
 * @brief fused 3x3 conv2d and ReLU activation function
 * convo
 * This function processes a 3x3 convolutional layer in a neural network by performing
 * the dot product of the input activations and weights, and stores the result in the output array.
 * The function also applies a ReLU activation function to the result.
 *
 * To simplify the implementation, some assumptions are made:
 * - The kernel size is always 3x3, and the stride is always 1 and padding is always 0.
 * - Only square arrays (x=y) are supported.
 * - Always the full array is processed, no border handling.
 * - The input activations are stored in a 2D array with dimensions (xy_input, xy_input).
 * - The weights are stored in a 2D array with dimensions (3, 3). The weights are assumed to be 8-bit signed integers.
 * - The output is stored in a 2D array with dimensions (xy_input - 2, xy_input - 2).
 * 
 * This function is intended to be used in a loop to process multiple channels in parallel.
 * Convolutions can be performed in place, i.e., the output array can be the same as the input activations array. 
 *  
 * @param activations Pointer to the input activations of the layer.
 * @param weights Pointer to the weights of the layer.
 * @param xy_input The number of input neurons.
 * @param n_shift The number of bits to shift the result of the convolution after summation, typically 8.
 * @param output Pointer to the output array where the result of the layer is stored.
 * @return Pointer to the end of the output array.
 */

/*int32_t* processconv33ReLU(int32_t *activations, const int8_t *weightsin, uint32_t xy_input, uint32_t  n_shift , int32_t *output) {

    // Create SRAM copy of the weights for speed up
    int8_t weights[9];

    for (uint32_t i = 0; i < 9; i++) {
        weights[i] = weightsin[i];
    }

    for (uint32_t i = 0; i < xy_input - 2; i++) {
        int32_t *row = activations + i * xy_input;
        for (uint32_t j = 0; j < xy_input - 2; j++) {
            int32_t sum = 0;
            int32_t *in = row ++;

            // Unrolled convolution loop for 3x3 kernel
            sum += weights[0] * in[0] + weights[1] * in[1] + weights[2] * in[2];
            in += xy_input;
            sum += weights[3] * in[0] + weights[4] * in[1] + weights[5] * in[2];
            in += xy_input;
            sum += weights[6] * in[0] + weights[7] * in[1] + weights[8] * in[2];

            // Apply shift and ReLU
            if (sum < 0) {
                sum = 0;  // ReLU
            } else {

                // sum += (1 << n_shift) >> 1;  // Add 1/2 of the shift value for rounding
                sum = sum >> n_shift;

                // if (sum > 127) {
                //     sum = 127;  // Clip to int8_t range. Important, otherwise the rounding can cause overflow!
                // }
            }
            *output++ = (int32_t)sum;
        }
    }

    return output;
}*/

/**
 * @brief maxpool2d 2x2 function
 *
 * This function performs a 2x2 max pooling operation on a 2D array of input activations.
 * The function divides the input activations into 2x2 non-overlapping regions and selects the maximum value in each region.
 * 
 * To simplify the implementation, some assumptions are made:
 * - The input activations are stored in a 2D array with dimensions (xy_input, xy_input).
 * - The input activations are assumed to be 8-bit signed integers.
 * - The output is stored in a 2D array with dimensions (xy_input / 2, xy_input / 2).
 * - The stride of the max pooling operation is 2. 
 * - Padding is not supported, so the input dimensions must be divisible by 2.
 * - Dilation is not supported.
 * - The output array can be the same as the input activations array. (in place operation)
 *  
 * @param activations Pointer to the input activations of the layer.
 * @param xy_input The number of input neurons.
 * @param output Pointer to the output array where the result of the layer is stored.
 * @return Pointer to the end of the output array.
 */

/*int32_t *processmaxpool22(int32_t *activations, uint32_t xy_input, int32_t *output) {
    uint32_t xy_output = xy_input / 2;

    // Iterate over the output array dimensions
    for (uint32_t i = 0; i < xy_output; i++) {
        int32_t *row = activations + (2 * i) * xy_input;
        for (uint32_t j = 0; j < xy_output; j++) {            

            // Find the maximum value in the corresponding 2x2 patch in the input activations
            int32_t max_val;
            max_val = row[0];
            max_val = max_val > row[xy_input] ? max_val : row[xy_input];
            row++;
            max_val = max_val > row[0] ? max_val : row[0];
            max_val = max_val > row[xy_input] ? max_val : row[xy_input];
            row++;

            // Store the maximum value in the output array
            *output++ = max_val;
        }
    }
    return output;
}*/

#endif