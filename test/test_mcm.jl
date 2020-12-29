using AngularPowerSpectra
using Healpix
using CSV
using Test
using LinearAlgebra
using DataFrames
using DelimitedFiles
using NPZ
import AngularPowerSpectra: TT, TE, ET, EE

##
@testset "Mode Coupling Matrix TT" begin
    nside = 256
    mask = readMapFromFITS("data/example_mask_1.fits", 1, Float64)
    flat_beam = SpectralVector(ones(3*nside))
    flat_mask = Map{Float64, RingOrder}(ones(nside2npix(nside)) )
    m1 = PolarizedField("143_hm1", mask, mask, flat_mask, flat_mask, flat_mask, flat_beam, flat_beam)
    m2 = PolarizedField("143_hm2", mask, mask, flat_mask, flat_mask, flat_mask, flat_beam, flat_beam)
    workspace = SpectralWorkspace(m1, m2)
    𝐌 = mcm(workspace, TT, "143_hm1", "143_hm2")

    reference = readdlm("data/mcm_TT_diag.txt")
    @test all(reference .≈ diag(𝐌.parent)[3:767])
    map1 = readMapFromFITS("data/example_map.fits", 1, Float64)
    Cl_hat = spectra_from_masked_maps(map1 * mask, map1 * mask, lu(𝐌.parent), flat_beam, flat_beam)
    reference_spectrum = readdlm("data/example_TT_spectrum.txt")
    @test all(reference_spectrum .≈ Cl_hat[3:end])
end

##
@testset "Mode Coupling Matrix Diag EE" begin
    nside = 256
    mask = readMapFromFITS("data/example_mask_1.fits", 1, Float64)
    flat_beam = SpectralVector(ones(3*nside))
    flat_mask = Map{Float64, RingOrder}(ones(nside2npix(nside)) )
    m1 = PolarizedField("143_hm1", mask, mask, flat_mask, flat_mask, flat_mask, flat_beam, flat_beam)
    m2 = PolarizedField("143_hm2", mask, mask, flat_mask, flat_mask, flat_mask, flat_beam, flat_beam)
    workspace = SpectralWorkspace(m1, m2)
    𝐌 = mcm(workspace, EE, "143_hm1", "143_hm2")
    factorized_mcm12 = lu(𝐌.parent)

    reference = readdlm("data/mcm_EE_diag.txt")
    @test all(reference .≈ diag(𝐌.parent)[3:767])
end

##
@testset "Mode Coupling Matrix Diag TE/ET" begin
    nside = 256
    mask = readMapFromFITS("data/example_mask_1.fits", 1, Float64)
    flat_beam = SpectralVector(ones(3*nside))
    flat_mask = Map{Float64, RingOrder}(ones(nside2npix(nside)) )
    m1 = PolarizedField("143_hm1", mask, mask, flat_mask, flat_mask, flat_mask, flat_beam, flat_beam)
    m2 = PolarizedField("143_hm2", mask, mask, flat_mask, flat_mask, flat_mask, flat_beam, flat_beam)
    workspace = SpectralWorkspace(m1, m2)
    𝐌 = mcm(workspace, TE, "143_hm1", "143_hm2")
    reference = readdlm("data/mcm_TE_diag.txt")
    @test all(reference .≈ diag(𝐌.parent)[3:767])

    𝐌 = mcm(workspace, ET, "143_hm1", "143_hm2")
    reference = readdlm("data/mcm_TE_diag.txt")
    @test all(reference .≈ diag(𝐌.parent)[3:767])
end

##
@testset "Full Non-Trivial MCM" begin
    nside = 256
    mask1_T = readMapFromFITS("data/mask1_T.fits", 1, Float64)
    mask2_T = readMapFromFITS("data/mask2_T.fits", 1, Float64)
    mask1_P = readMapFromFITS("data/mask1_P.fits", 1, Float64)
    mask2_P = readMapFromFITS("data/mask2_P.fits", 1, Float64)
    unit_map = Map{Float64, RingOrder}(ones(nside2npix(nside)) )
    unit_beam = SpectralVector(ones(3*nside))
    m1 = PolarizedField("143_hm1", mask1_T, mask1_P, unit_map, unit_map, unit_map, unit_beam, unit_beam)
    m2 = PolarizedField("143_hm2", mask2_T, mask2_P, unit_map, unit_map, unit_map, unit_beam, unit_beam)
    workspace = SpectralWorkspace(m1, m2)

    𝐌 = mcm(workspace, TT, "143_hm1", "143_hm2")
    𝐌_ref = npzread("data/mcmTT.npy")
    @test all(isapprox(𝐌.parent[3:end, 3:end], 𝐌_ref[3:end, 3:end], atol=1e-11))

    𝐌 = mcm(workspace, TE, "143_hm1", "143_hm2")
    𝐌_ref = npzread("data/mcmTE.npy")
    for k in 0:3nside
        @test all(isapprox(diag(𝐌.parent, k)[3:end], diag(𝐌_ref, k)[3:end]))
    end

    𝐌 = mcm(workspace, ET, "143_hm1", "143_hm2")
    𝐌_ref = npzread("data/mcmET.npy")

    for k in 0:3nside
        @test all(isapprox(diag(𝐌.parent, k)[3:end], diag(𝐌_ref, k)[3:end]))
    end

    𝐌 = mcm(workspace, EE, "143_hm1", "143_hm2")
    𝐌_ref = npzread("data/mcmEE.npy")
    for k in 0:3nside
        @test all(isapprox(diag(𝐌.parent, k)[3:end], diag(𝐌_ref, k)[3:end]))
    end
end
