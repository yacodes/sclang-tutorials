(
  play{
    a=Dust.ar(3);
    GVerb.ar(
      BPF.ar(
        Decay.ar(a, TRand.ar(0.1, 0.7, a), BrownNoise.ar),
        2**LFNoise0.kr(4 / 3, 3) * 1024
      )
    ).distort!2
  }
)

s.freeAll

s.boot

s.boot

Platform.userExtensionDir
