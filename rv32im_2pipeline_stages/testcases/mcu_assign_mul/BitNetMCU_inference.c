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
                    sum = sum + weightChunk*in ;
                }
            }   
        output[i] = sum;
        print_str("."); 
    }
}



