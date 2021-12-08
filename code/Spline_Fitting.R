gam_mod = gam(violenceScore ~ sex*UnemploymentRate + sex*SNAP + s(sitename, bs = "re"), data = dat_keep)

pred = predict(gam_mod, dat_remove, exclude = "s(sitename)")