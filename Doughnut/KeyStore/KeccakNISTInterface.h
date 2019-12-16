/*
 The Keccak sponge function, designed by Guido Bertoni, Joan Daemen,
 Michaël Peeters and Gilles Van Assche. For more information, feedback or
 questions, please refer to our website: http://keccak.noekeon.org/
 
 Implementation by the designers,
 hereby denoted as "the implementer".
 
 To the extent possible under law, the implementer has waived all copyright
 and related or neighboring rights to the source code in this file.
 http://creativecommons.org/publicdomain/zero/1.0/
 */

#ifndef _KeccakNISTInterface_h_
#define _KeccakNISTInterface_h_

#include "KeccakSponge.h"

typedef unsigned char BitSequence;
typedef unsigned long long DataLength;
typedef enum { SUCCESS = 0, FAIL = 1, BAD_HASHLEN = 2 } HashReturn;

typedef spongeState hashState;

HashReturn Init(hashState *state, int hashbitlen);

HashReturn Final(hashState *state, BitSequence *hashval);

HashReturn Update(hashState *state, const BitSequence *data, DataLength databitlen);

#endif
