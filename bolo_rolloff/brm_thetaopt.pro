FUNCTION brm_thetaopt, vr, vi, phi
  numerator = vi^2*SIN(phi) + 2.*vr*vi*COS(phi) - vr^2*SIN(phi)
  denominator = vr^2*COS(phi) + 2.*vr*vi*SIN(phi) - vi^2*COS(phi)
  RETURN, ATAN(numerator,denominator)
END
