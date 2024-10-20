<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE fontconfig SYSTEM 'fonts.dtd'>
<fontconfig>
 <alias binding="strong">
  <family>emoji</family>
  <default>
   <family>Apple Color Emoji</family>
  </default>
 </alias>
 <alias binding="strong">
  <family>Noto Color Emoji</family>
  <prefer>
   <family>Apple Color Emoji</family>
  </prefer>
 </alias>
 <alias binding="strong">
  <family>Segoe UI Emoji</family>
  <prefer>
   <family>Apple Color Emoji</family>
  </prefer>
 </alias>
 <alias binding="strong">
  <family>Emoji One</family>
  <prefer>
   <family>Apple Color Emoji</family>
  </prefer>
 </alias>
 <match target="font">
  <edit mode="assign" name="rgba">
   <const>rgb</const>
  </edit>
 </match>
 <match target="font">
  <edit mode="assign" name="hinting">
   <bool>true</bool>
  </edit>
 </match>
 <match target="font">
  <edit mode="assign" name="hintstyle">
   <const>hintslight</const>
  </edit>
 </match>
 <match target="font">
  <edit mode="assign" name="antialias">
   <bool>true</bool>
  </edit>
 </match>
 <dir>~/.fonts</dir>
</fontconfig>
