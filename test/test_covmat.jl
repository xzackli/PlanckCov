using AngularPowerSpectra
using Healpix
using CSV
using Test
using LinearAlgebra
using DataFrames
using DelimitedFiles
using NPZ
import AngularPowerSpectra: TT, TE, EE


@testset "Covariance Matrix Diagonal in the Isotropic Noise Limit" begin
    nside = 256
    mask1_T = readMapFromFITS("data/mask1_T.fits", 1, Float64)
    mask2_T = readMapFromFITS("data/mask2_T.fits", 1, Float64)
    mask1_P = readMapFromFITS("data/mask1_P.fits", 1, Float64)
    mask2_P = readMapFromFITS("data/mask2_P.fits", 1, Float64)
    unit_var = Map{Float64, RingOrder}(ones(nside2npix(nside)))
    flat_mask = Map{Float64, RingOrder}(ones(nside2npix(nside)) )
    beam1 = SpectralVector(ones(3nside))
    beam2 = SpectralVector(ones(3nside))
    theory = CSV.read("data/theory.csv", DataFrame)
    noise = CSV.read("data/noise.csv", DataFrame)
    identity_spectrum = SpectralVector(ones(3nside));

    cltt = SpectralVector(convert(Vector, theory.cltt))
    clte = SpectralVector(convert(Vector, theory.clte))
    clee = SpectralVector(convert(Vector, theory.clee))
    nlee = SpectralVector(convert(Vector, noise.nlee))
    nltt = SpectralVector(convert(Vector, noise.nltt))

    # this test specifies a map with unit variance. the corresponding white noise level is divided out in r_coeff
    N_white = 4π / nside2npix(nside)
    r_coeff = Dict{AngularPowerSpectra.VIndex, SpectralVector{Float64, Vector{Float64}}}(
        (TT, "143_hm1", "143_hm1") => sqrt.(nltt ./ N_white),
        (TT, "143_hm1", "143_hm2") => identity_spectrum,
        (TT, "143_hm2", "143_hm1") => identity_spectrum,
        (TT, "143_hm2", "143_hm2") => sqrt.(nltt ./ N_white),

        (EE, "143_hm1", "143_hm1") => sqrt.(nlee ./ N_white),
        (EE, "143_hm1", "143_hm2") => identity_spectrum,
        (EE, "143_hm2", "143_hm1") => identity_spectrum,
        (EE, "143_hm2", "143_hm2") => sqrt.(nlee ./ N_white))

    spectra = Dict{AngularPowerSpectra.VIndex, SpectralVector{Float64, Vector{Float64}}}(
        (TT, "143_hm1", "143_hm1") => cltt,
        (TT, "143_hm1", "143_hm2") => cltt,
        (TT, "143_hm2", "143_hm1") => cltt,
        (TT, "143_hm2", "143_hm2") => cltt,

        (EE, "143_hm1", "143_hm1") => clee,
        (EE, "143_hm1", "143_hm2") => clee,
        (EE, "143_hm2", "143_hm1") => clee,
        (EE, "143_hm2", "143_hm2") => clee ,
        
        (TE, "143_hm1", "143_hm1") => clte,
        (TE, "143_hm1", "143_hm2") => clte,
        (TE, "143_hm2", "143_hm1") => clte,
        (TE, "143_hm2", "143_hm2") => clte,
    )

    m1 = PolarizedField("143_hm1", mask1_T, mask1_P, unit_var, unit_var, unit_var, beam1, beam1)
    m2 = PolarizedField("143_hm2", mask2_T, mask2_P, unit_var, unit_var, unit_var, beam2, beam2)
    workspace = CovarianceWorkspace(m1, m2, m1, m2)

    𝐂 = AngularPowerSpectra.compute_coupled_covmat_TTTT(workspace, spectra, r_coeff);
    𝐂_ref = npzread("data/covar_TT_TT.npy")
    @test isapprox(diag(𝐂.parent)[3:end], diag(𝐂_ref)[3:end])

    𝐂 = AngularPowerSpectra.compute_coupled_covmat_TTTE(workspace, spectra, r_coeff);
    𝐂_ref = npzread("data/covar_TT_TE.npy")
    @test isapprox(diag(𝐂.parent)[3:end], diag(𝐂_ref)[3:end])

    𝐂 = AngularPowerSpectra.compute_coupled_covmat_TETE(workspace, spectra, r_coeff);
    𝐂_ref = npzread("data/covar_TE_TE.npy")
    @test isapprox(diag(𝐂.parent)[3:end], diag(𝐂_ref)[3:end])

    𝐂 = AngularPowerSpectra.compute_coupled_covmat_TTEE(workspace, spectra, r_coeff);
    𝐂_ref = npzread("data/covar_TT_EE.npy")
    @test isapprox(diag(𝐂.parent)[3:end], diag(𝐂_ref)[3:end])

    𝐂 = AngularPowerSpectra.compute_coupled_covmat_TEEE(workspace, spectra, r_coeff);
    𝐂_ref = npzread("data/covar_TE_EE.npy")
    @test isapprox(diag(𝐂.parent)[3:end], diag(𝐂_ref)[3:end])

    𝐂 = AngularPowerSpectra.compute_coupled_covmat_EEEE(workspace, spectra, r_coeff);
    𝐂_ref = npzread("data/covar_EE_EE.npy")
    @test isapprox(diag(𝐂.parent)[3:end], diag(𝐂_ref)[3:end])

    # test that planck approx is kind of close at high ell
    𝐂 = AngularPowerSpectra.compute_coupled_covmat_TEEE(workspace, spectra, r_coeff; planck=true);
    𝐂_ref = npzread("data/covar_TE_EE.npy")
    @test isapprox(diag(𝐂.parent)[30:end], diag(𝐂_ref)[30:end], rtol=0.01)


    # test decoupling
    𝐌 = mcm(EE, m1, m2)
    𝐂_decoupled = deepcopy(𝐂)
    decouple_covmat!(𝐂_decoupled, lu(𝐌.parent'), lu(𝐌.parent'))
    @test isapprox((𝐂.parent), 𝐌.parent * 𝐂_decoupled.parent * 𝐌.parent' )
end
