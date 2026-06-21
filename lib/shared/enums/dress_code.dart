enum DressCode {
  casual,
  smartCasual,
  businessCasual,
  business,
  blackTie;

  String get label => switch (this) {
        DressCode.casual => 'Casual',
        DressCode.smartCasual => 'Smart Casual',
        DressCode.businessCasual => 'Business Casual',
        DressCode.business => 'Business',
        DressCode.blackTie => 'Black Tie',
      };

  int get level => index;
}
