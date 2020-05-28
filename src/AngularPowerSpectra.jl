module AngularPowerSpectra

import ThreadPools: @qthreads
import Base.Threads: @threads
import UnsafeArrays: uview, UnsafeArray
import DataStructures: DefaultDict
import Combinatorics: permutations, combinations, with_replacement_combinations
import Healpix: Map, PolarizedMap, Alm, RingOrder, alm2cl, map2alm, numberOfAlms
import WignerFamilies: wigner3j_f!, WignerF, WignerSymbolVector, get_wigner_array, 
    swap_triangular
import FillArrays: Zeros
import OffsetArrays: OffsetArray, OffsetVector
import LinearAlgebra: Cholesky, ldiv!, rdiv!, Hermitian
import LoopVectorization: @avx

export compute_mcm, compute_spectra, compute_covmat
export Field, SpectralWorkspace, SpectralVector, SpectralArray

include("spectralarray.jl")
include("workspace.jl")
include("modecoupling.jl")
include("covariance.jl")


end
