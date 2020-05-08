## load in the data
using AngularPowerSpectra
using Healpix

data_dir = "/home/zequnl/.julia/dev/AngularPowerSpectra/notebooks/data/"
# flatmap = readMapFromFITS(data_dir * "mask.fits", 1, Float64)
flatmap = Map{Float64, RingOrder}(ones(nside2npix(512)))  # FLAT MASK

m_143_hm1 = Field("143_hm1", flatmap, flatmap)
m_143_hm2 = Field("143_hm2", flatmap, flatmap)
workspace = SpectralWorkspace(m_143_hm1, m_143_hm2, m_143_hm1, m_143_hm2)

AngularPowerSpectra.w_coefficients!(workspace, m_143_hm1, m_143_hm2, m_143_hm1, m_143_hm2)
AngularPowerSpectra.W_spectra!(workspace)

##


##
using BenchmarkTools
@btime cov($workspace, $m_143_hm1, $m_143_hm2, $m_143_hm1, $m_143_hm2)

##

##

using WignerFamilies

@time res = wigner3j_f(20000, 20000, 0, 0)

# using PyPlot
# plt.clf()
# plt.imshow(log10.(C))
# plt.gcf()
