module AngularPowerSpectra

import ThreadPools: @qthreads
import Base.Threads: @threads
import UnsafeArrays: uview, UnsafeArray
import ThreadSafeDicts: ThreadSafeDict
import DataStructures: DefaultDict
import Combinatorics: permutations, combinations, with_replacement_combinations
import Healpix: Map, PolarizedMap, Alm, RingOrder, alm2cl, map2alm, numberOfAlms,
    RingInfo, getringinfo!, almIndex, alm2map
import WignerFamilies: wigner3j_f!, WignerF, WignerSymbolVector, get_wigner_array, 
    swap_triangular
import FillArrays: Zeros
import OffsetArrays: OffsetArray, OffsetVector
import LinearAlgebra: Cholesky, ldiv!, rdiv!, Hermitian
import Distributions: MvNormal
using Random
# import LoopVectorization: @avx

export compute_mcm_TT, compute_spectra, compute_covmat_TT
export Field, SpectralWorkspace, SpectralVector, SpectralArray
export PolarizedField, PolarizedSpectralWorkspace
export compute_mcm_EE, compute_covmat_EE
export binning_matrix
export generate_correlated_noise

include("util.jl")
include("spectralarray.jl")
include("workspace.jl")
include("modecoupling.jl")
include("covariance.jl")


end
