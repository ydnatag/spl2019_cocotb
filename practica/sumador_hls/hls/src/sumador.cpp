#include "ap_cint.h"
//using namespace hls;

void sumador (uint4 *a, uint4 *b, uint4 *sum)
{
    #pragma HLS pipeline II=1 enable_flush
    #pragma HLS INTERFACE axis register port=a
    #pragma HLS INTERFACE axis register port=b
    #pragma HLS INTERFACE axis register port=sum
    #pragma HLS INTERFACE ap_ctrl_none port=return

    *sum = *a + *b;
}
