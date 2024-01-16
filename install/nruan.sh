#!/bin/sh
skip=49

tab='	'
nl='
'
IFS=" $tab$nl"

umask=`umask`
umask 77

gztmpdir=
trap 'res=$?
  test -n "$gztmpdir" && rm -fr "$gztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

case $TMPDIR in
  / | /*/) ;;
  /*) TMPDIR=$TMPDIR/;;
  *) TMPDIR=/tmp/;;
esac
if type mktemp >/dev/null 2>&1; then
  gztmpdir=`mktemp -d "${TMPDIR}gztmpXXXXXXXXX"`
else
  gztmpdir=${TMPDIR}gztmp$$; mkdir $gztmpdir
fi || { (exit 127); exit 127; }

gztmp=$gztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$gztmp" && rm -r "$gztmp";;
*/*) gztmp=$gztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `printf 'X\n' | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gzip -cd > "$gztmp"; then
  umask $umask
  chmod 700 "$gztmp"
  (sleep 5; rm -fr "$gztmpdir") 2>/dev/null &
  "$gztmp" ${1+"$@"}; res=$?
else
  printf >&2 '%s\n' "Cannot decompress $0"
  (exit 127); res=127
fi; exit $res
�_-�enruan.sh �=�sE�����t�Ȋ=��� G�[� Pd�
��&�؞D���v��V8�|q�[BX |$��6NBH��+'��O�/�믙��Yr���I�3=�_�~���ׯ���ޥ���qÙ��E��sLw(���T͊i���]+���c�@r8�̚Sc�$-/Z�snn�j���������I��)>ggr�CC�=�ѾT��.Vw�CbTK��J�p�\~�̟J1�g���#�F�5����Q�.WkFyԙ�КASH3N�U0��D�Y��'M�̢czE�Ҫ3H�Ŵ��Fz���˵bM<�g�CV�GP\em&�~��4'����X\���]@Ë��bƢf-w�v���������vy��R6Jf�c}[e�5�E=�3�Y���9 Κ��BεJ�'��	�T	W��b�����6
t�Hˣ�7�h&���q�4b`3h��Ex��
4m��l ���=�� �u��������|H>uyP��C�Z�b�"�s�[qҺnT�Q<��K:EGOHcJ�5ˮ��]:�f�!�,�I�h�<1N"��L�$J.�JՂ靘@�d�mdF#� �P`4<�� �9:h9���Ԡ�J���a���%�u�"��LAxx�}����oӃ/sD x��d�H�G'�D{���@6�/�)`�g|tt�U�V��Qq5��3i��N�r4pnެ:�]�Y�:Dʀ V�����He1�I�ux��%1�bH�ۋ����(Р���5w��Lf�k���9J`�1����^:��B���Zޮ�ғ"'��8�M�-~I�D�,��c::�J�Ѫh�5f�T��et3f��Q��^9#U��/�,��-v�5���J�e8�5[.�L�4l�\��jV!G!2C�Ov��(��J��f٬;-9�<V�W���YA�7��O�����֍o[�4�h.�iݸ�X=���õϮqy���GP�s��?l�.����kƩ�/#�}�^l�~�v��ୋg�ŵ�Z�4~�z��.D�hz�m0��I��gk��\���囍�wZ߄��W�c�ڧ��gw/ Wo5/|о}�u�"zέ��C͟�?��v���ǟ���h�
JPWi_	��y��|�}�-�ٺp�u��E��[@������~X?%͐$����BCCVf|Y�3	� .��S�IT�=u"FĊ���-�X�31��gA1��(�Q��(��v$(Qġ
v�Ă�T� :B�.�w�0c��|�El?S>�ϔ���{c#h�̙��{�+7�+��ϙ�U�h�b�4����M�V-�q�3��/���2!��5�#���U>-��a�j�M�����f��l�A��A
���E4}B+�fV~�9{!v)G�����D)tCn4Z�f;п�*zV)��g���'�De/��;*�P\���zP;2�� b�|M=�Z���X��5V�A��7׾�7-��Lq>�UD�`� ��C1e4��.c$�(4���
Abiw��S�L�c$B����wfc�5�? I�	Ӹw��ř֧7[���������0��z�}�mF���7�#_��c�\��e���05�=eh3��^�^:T�����܎O�hZ�8�";F:�	�*M�:��X]�P�[�q���Ҽ|.4��������Ï��� �D�����O�Q��j/��6�V WKA@"8 ]���0!�n+�j=��Ǭm�>%�������w��Gf%u���G?�bqS��+T�S��6t8��<֒+��҂+���r����b���Bi��-�ʕ���Gmr�%`���f	B��������W�3��J>�A�+���������@�}w��}���ŜP�O>$<�	|�����ÿ[ǿ�.����?&b����
����h���;.K\��g׮�k��N�����Y�480�-���,(�H��eȸ��G]�ݨ}�N��uFC����Y)���RRm�z�ڽx\��p��f�$����(�q�xM��j���dtϞ��� �p�N�$	������Yo��3CY�Η�#�8�����t�b�������wVUv?��z�Q��z�Q-.��`dSZ'��ifX����F7�8-����[�E�8ܜG��K:�����,�M�@46�,t8����0�Wf��K�|=�'c��%i���L[ewƷ��:����2�a�F��O�p_��F�V��+��>S�m��Am���c�w�r���О�G�7�$������R,�%�[�u��m0�+>�KƇ�E��X
�ihl�RQ�� ~}�w��v��P�PE�YC=.m��Y3n�[�?������jb�p�a��$�VI��(<���'��06�D'0
�.$zi�g>��\��9i\�Қ��3)\R	���v`g}�nW�2��k@�F4�3Bpk��k��he�R�J�nwъ���Mn��j��&�͑�3Y9iYBk�[�.6��o���~����k͏>i��g[&4��>p�p̃�C�����N������^Ƿ.\���؂~�k�Sv���bx�;T�r)f�S�}2��Ս�o,���t=���)�Jh���$����[%y=I}8	7�M��&&Rq8�38��m�gy�����@7<��cG���^y����ϼH���3k����S�-g��eR&�jN���	���d����k�o���#d}��
���g.���:0���"�K�ʊ.��iȲ3y����È݌�?l��d*�(	5Uc�'Ԑ�Ox��5~>�NVq��U|���u���c�dW:EӬ�	���� O��+�(�f���g��b\_�C�\0�o�
�Q+��s�u0PSA��C�x��ch	�Z�^�;,H1+��Hm�߳B�]c�	�[���Pb�1�MI��*{Vp�>��5��訒T
�H̴_EI�p:�����������m�#��K��@�Q�p�O��*R%)�1�x�)���}Ψy�$��%���,ӝ�*v�����\�̢[t�j����[$���)��1L���;'�C���أ6A�,(m`�(:�h� 	R�	%h,���DHPn,�תU]�4ü-
���G~�hR��Q&�M�P��\3�ݞ�(J�6�㩔���P������*��/�)k=�z6@j�HR���h	A�U��
�KO�d��$&�<=t=)�FwS�����d*�0�6���(��p�.�c��̟H!	˪��,Q/*�ӭ
�.je��K��\�3�%I�eˤ��]�W����N��UP�$��l�$���8�g@�1e��B���ܚ��p��j
���KG��-�D�\4�Mx>VO*�/��U��@+RP7B�V�F�`���`W��ۙ3
��c�OR���Taux��e/� �3I¹���pB*��`�s���T�V����t�\�:p�
`�[C�p�	�F�8�\_���R��|'�\�չ�G2�j0=�>Z �D�����݋���p���pU�W���p#F�2��L%�7^Dt7�6��ɇW1o�����=�U�1�9�'�k�X��숎S#8K��E�X�1���L�s��v3���KO�?ۏ9��&'��]�\v�I�g[�fx�d����C2� ���_ODJ/$=�V�Scۜ��c��q ����[��|`MS)=�s�*�
�M� $4K�K2��$(�	�{�a�t�F���%Z��`�'}*��ֳ�=�l2J�A#<�	��v����\�̦Q6dB��}qD��+J�6�E�ͥ�վ75��Y��f���*�yɏV���#?Gc�(+.C�b�T���qV�-(��#�1��Ç�DAHLlB��H��M,qG�,�W�y}�������t9ߨ��_�7�Z�h�y���^%H�F���B�U�XB�b���~ٍX6�����i���勪��O�<�ü��΀"�rR�>[�i�d�WSi�b�����ޘ�NKY���r�.��\�/V�*���@tRGЩ'��+�5��ҭ�$��&�H�zA9͔�
��o�<��	]):"��%��N��N@'���C@���|@�F?�#Q��yb:�3|k:ѭ�:!�?�i�-���?h@�#v:=t�R�v:;����N@�I�<zDG��sDG��Ft������ё8�MDG�omD'����?JD'�5����ϯ}}�$�F�F��/�������h�x�ʋ��-)�w�A6_c�+,E^��H(J�fKBQrc�BQ\�BQ>�����K@��G�f��?�,�AQ*�G���qf��$E��K=�%�V>/"��W�0�#B��W\@��H���`�Ï�t�0���Q�y�b!6dT��T�)rkV�;41�%ֲa͛-��4�BQ�x<
z���Y��ᤨc�s8)���">J8I��O��s��t˘x�k�(ϼ�$���*��/�yP�Q���<9�.��ץ'��T%>z��'��ļ�a^,}�sw�'?$��9�C��ch�����4	���"��_;J}��3��ϼ����<��&x&��6xh�	�	���<9�oE���=��������I,E��R�\A_�'��I�0���[�_���%��5������w�_^���p�:8�]��>ʑ��v�����`|�zH�56���m*L���A�t�7Oٙ,�H7z�/��=,M�WE��O3R�nFv0i�Yw���cPؚ���LFq,΁�Y4|α�q"$b�=��ٙ��V��r���R)��q=����<3��׻����`v�l?�EΘݼ�R��-�e��2�N.���1^;�k�xm�U��-{=a�q/-�UG)����Xi�6�&�_��0f��%3�!�6����04�t�%�0��6p�FO�o�{ؽ�9H����(�_�$�&�M�՝��Y���O�(�@T�S�]5�N�p�-hZ�K��p���ע� |d5W����2|����#�[be$0	#���2_�s��ث(\������`���b�f�+Qq(8q�,I�~p�#;�l;�b�0l4����d�"	1�=��=��@��N��V#�N���Zݵ��R9�`ܹ��q�1���s4�!'��c;��H��%.u.E��M��N-17��0S��#�R�0|b`�Jh�@�3��(�\ڗx?O�~�����~��Ii#�n�Q�G����=�&�Gc�����h;V�[��Ĝ��-�9g^x��,��^�\�rOUH:��^�U�cL��Tx=�.�#$���f��{v�$��?4-�5�9���NH���k[1~�A�;��7���+k�g�D�C8��N{����������}�^���'�uxu�j�vm@N.�������q���<���ޚ�ٛ�[����"��D�x��E4P�*�D��3���:�j��J��0	�^�l����\)���@��ެ��i?ǎI�ap7�F����D��H�	��Qk�],osc:��d�wpor�I
_����@�[N{����"�g�XBM%P }F�T�~7�"�R�谟	�!^���X#�H�c�nce�.��,km�(����e&a�����{��><�Ndf�N����P�H�S\W5�=���K��H�I�I�(;�h%�`Ng�8�G�����k>�`��%��ŝ�ߝʏ��)AZ�v[܉�bA(]C0�î���,�H��=uʻ�I�Г�J��r��/qe���Ϙ��t�۹�!��/�T�)4�9�l����[F�hl;i�db��?c��?��Y�Wv�E��θ�]]�n�(�=ˌ�+i�K%���ϻ�v��I�~�^Z�����u���.��tն�c�e�����U���`��f��
�]�q|��������:	SHd�;��s1g}t`[���}��&�)=�uc�ȑ<�iS�C���
�0R
�D�F�\���8�o�U��@��j �'tmҗ�ĨO�:��}4,������$^�?D�#�$G���J���kG��$�c��M�%�\ӣω2^�����n^�q)���т�wt��ϑ��1E���}3�}/�~$�u�C�u ]�G���%hU�h�9�̥0z�b��[�mW����"��U
�k��&}|��r3j}�E��W��/��X&���?6~����כ��G����o?g[��m���Z���y�qw�~V�}�j���k�]l��<::*��+�����ߖ�Ϗh^8���O[�ּ�+����k?�_��i����<���������F^�}<:1D������`I,��ߦ_N�)��b�O�t�L��s�M�EOĪ��Y�T�B٩�9f{�|H�f���{��U��g�e�LHw�@	f�\ѹ���Y2k�;C0��9	�������Y� ��
(�Q��^���tw>����:U��9�	Q���S��_�k��6p�L
�g3#���������������x:��MŦ6o����<�|d\�q�ɒy̷[�FT45�{i�r�G��h�L��R;r�9z�m��$Z|���	;��iG�K�5n~I��YK�/oS���.fJ�#@#y�PBbo��J��%N�c���^)썧&&�ሠ?$3#�ܻ��q*1i�����ف �`L���K���٦��>��P�h^K��������*yo�R-WLH�Tv����;�x�A�޶��R<��!ã��\/����c�bF��}DP�����|�Dɞ� f�0�C������Xf/()�om���7�:���@"U,�9�f�aw�E�6M*e��@�Wײ�=����?�%�<�R��3�8HTھ���[����IuJ�J��T���4��{*�^Ol�T=Ӥ����J/��J�Q٠=���N�R�k�*���m�m�8���k�m���vc�m��I�V�|2�;pV���T�o8����9�ř��tu�*��%���_u�MW���6��\9�l���v� �T��;��vU�����h�����#g� ��ұ~	�&��.#�1E�NPfn�ɉë�_�����.�}��y6*aI4I���	<|���?�^[��Mv��dZ���������ߛn|�E��'��j�,B4߄�潼|@���9r�z�	G \fPhf�1}�bˡ0��|@#������(���: �̆��I6�JYrO.ʒ��1�������}gn�z�K��^���7�R��X�_�}9 &��.ey�0�������dΥ���
r�:�~ ��Ƀ��pa~�9z�9uȹ�!�D���ˇ��{�Jh�l�)#x%[��t�݂�a��\X���l#oYid�L#�ؓ#\����bBb83�f�ݓc�.+�ݴ	we��T��@iQ��{�8ި�s��^|n�sJÊ2#�Վ�Y�����O�_��.�s���\ه�w�#�s������� �iz���]�w4�;����r�� �i|xq���僰��_1��[����p�v�6�� �;|ӄ�������Ԏ�r����>̅>�O�����7o�>9Q����'�ٲ-�6,�@�p��/��nR�}޹�}�y�I!@]V0	��a� q8h=����+�A��.ߵ�6�s���	;�.T���vD}�vm�hm�+�~ՙ;Z;�z�3;�XX�.��|?\���YQa����@ZeK�H\ʋg����{3�k�
?C���fљ�p �~���7����k��_������%`���\B�`��7���̘-���M�x��U[e�2n�����@4�5��"��?�;�0�yp0ʻɫ{�VJ��n�N|�\ ?ֿ��q�\��|��)�yz`&Y��)�8X�-v7?l�۫19��K��Z��������Z9 ��j6W��?�f�,�@ԅ��]�Zi����{~2'V�t���P����7I�Ne$��.��]���0�H��ܩI���N��;����i#w�47����
v����j*��������)
�{���X�2w=ϙ��dH�<��k�[�	(�H��6��%����z�d?��#��W�S|�CP���M��ݭ޻W}p5��i�j�ٲPt����p�ٷc�կ������Y���_�1 �U��W�W�?����~����;D���a�Yt�R�8����m��&���.�p^�S+Y�]�����row%����}~���<�1����r3��y$���v�h�/y|����|Z9l�i�W���|�SG$��+��½6X���:9sa���V�5�0�V��2c<�q���Y}fefG��ШN���+�S SE��:ӟ
�7�K�һ��an���B'B1��IZ�T��N#��eOf�2m43N6�0?D`���@Ơ�_
2̻&*- *�>+��nw�/���KV<Qn<�`��w�;���'^T�������z7����Z>���P�R���������6���5���v��o�w���wt�4�_'��Aq�`����	�
G"aU�k娾�fT�/1]}��nWh[�l��P?м#tsR[:�-5ޗ�v���UJ���P�x�������)Ce�{hn��Z%�ʧ��&J�[E�'��g�/L�/\c���9��k�>����M���xr�ȿW� M��cBX�ѲҬ2l��4&[z75[�������1X��8��g��_��A��eo����$����{�Ŋ�8��c�4�U&�I��2���l��Yx۞���jӈ�޵�q��J�z7m�"��ʏ���ؙ��mC����,�!A�����j�x[�C��צ�V���a#�f^~�V�ù�9&S��BG�V��	�!�ŝ��#�r$��[��x_�lYpW�q[V�0���1T�)~P1u��JD]|q�*5����6�Ǡ4
 6ĸP����1�������U��]�w��g��Sե;���opj�_{��z�![CG)k|�1\ϋ��?>3G1Ҽ����,�� ���z��<)��ZM��I��M==PdM!��To��	��$j�b�#$�
�a��>9���+�B��Dޝ+��^xAkXEv�/�K��:�k��������G7��T���8�:��&�	�>����(�EZta!�Ay�^LMř��Qpg;����m꺤9%�L�'Sل?\��(C1� �N �J���eO�G�C�ëQ��EF���g�ຨ=4]�r�7\�>�y���'�;���M�����iNR�q6^�BN�bM�)Z���:�^VgD2�V��%�	w��������;�A�U}�`�[m瓗��1��{�������De|M��JT�)�q���+�~Z�T ��ʹ2�sN.:G��+w*Ah�ӽ���2\r܎u�r2�ŊhaVq�@���2S����6&tĄkRL�J�#�:(���M�	a�-ߡ8���,UHbR"VpDv�,��G!��QI�BH&�	%#�5�%I@��Z�<[ӢkA|=���c�'����R��s�]�_�VI�\�O>W\�m�me�tIڞ��a {<����$��}r�J���q�]�!Etc�B�/�icqX��؀��>~�̠p��}'�a)O`�6�4Y̓�f�Qm��ɲ���[���q�t*0r�=b癩޵�SЭڽ���_r�08Wx�*b�]o!��"�H��E껄��M�]~�1-�-�)g�z�ۊ7��TQ�&{H�qn�F~h�����T��؄��d��c,�~T>ʊD�|Xvh1�Rq�s���]��
�&trf�N�Tal��Ŏ�^D45�HDP�e�2i�C�6��hG���80E244T�Ady5ǡH�
�+M%+�L��;��aB��H�Qvv*��X,V@ѱ ����a��+=�8���8��`$~��ŅnR;say~�9�4}��t�
�y�$ЬK�\�qk�y�!�V>90 �>�?���[?��C%@���^"=�4,%���pvQ�v0���M٩U�#3nQ0�� >�}����r�a��W��F��Vi��� {~@m�=�JO��)ʸ�GE<�j ���ջi�0����E�p��j�F�-۞��U�5��g�t�?_��냤̒�����Hf<_(Z�,��H*?Jc���ª;A��b��V��,�F���'A��J����I$�~�.�)���tr)��bj�b�[XՕA�� @e�PnV�Z��H�¤��}w+m���t�#D��D�l^����մ殖���F"kqF�k�B�D8z�? ��:�=��N� y���[^���M�}�k�ʛ�+��$�����kM��6�S�hD�����dAG�Gp�._wA��he]
Q�,�IM�}�H[�V�p��M�iBADW����9��N(s�?����6ڙ�I,�zII�5��9Β>��������v��:��I��x��e�t�	Л\�KDG�����5^����\��9�f8�e�X���'v�RY@|�ٷ����f�K��V>���m�?�D��3?���4=�W@&�D�.�d�L�`D�3�h� ��$�����`nJ;��4F��*��C��`X$j�AI˴�Xn _AU�З)m\���Fٔ]F�}�<�Zs���2Y����w���G;�7Nz��
�@�o�P�n9+���T�f��Lx;�y���Ѳ;�Jw�,GQ	�4G�P��Y�bwgX�#X��w& ��Sm9іm9іm9�ȉ��7�N�5̍L=���4y�y�!�'���Il���p.5a~�b���?
��S>r�5�{�"�`4�@`nJ�������ps�rĨϋS��^}�&>��Ĉ�lI 54��q��m����.�c�ߣӼ��{v>E��Ǹ�i<;[<��M�5�z��w2��"_�¹�D��@�|v������R�a�K}Y[�k����J���?�j#�]�e�|B�~Wa�;%�ē��x5�7������]2��Q��oE�Ε�q0d렣�R�*���� �J$�A����@��o�=n?���V��v�50�,O���
���]*vNt�d7�/_�uF{��ˢ�_)�������ܚyi�W�����t'�\��s+.�V��4*z��:���҄x$�^�М}k����*OC��(|�o��o�ەtOע>���T}17A	��9����0,��ْ͇~�ߜ�G��"�'!A!��<y��xfF�᯺~U�%�f1���]��B�kT���Ko��g��~�Q���ȅ���E;�G�#�=* b%�r���C������Q�����n.�=V@X�>��@�X��p�V)ȧ�8��C��E
�����}���y�I�G!���6���d����{�].݇����|��;ؕ#r`����d%���f�^-�~�]��G�M�&�K�H�ϭg{���n�m�۶�m����v�v�m�ݶ�n�n�m�۶�m����v�v�}��n=v64õ�lm#[���6������vbl;1���N�ψcUӬ�$�R��R�u�n��C��o���i*�m�� ��D�g�O	�zp�T�LL4�o���LN w��@5y#i��y�n�~�ޖ�G�>�q��V:O�)�B;nAT�F9���MI�B1���$�915*�r�z}J�q�r��L!��bҡ�	5=�E;GR�Eq�7��פ=3�@�r]|}%$�w▲L8I��V��ǟ����Շ�1F+SY���&N�=�.�;=�C�S�H�rxH����ֈ���m��q�����'ݽ�ܒz��_v�e~p兒�o�QM��)�[��pA�BOL-�bHU�>78�9hvS�����0xѧl�v�w�,��{�mx���������K��;���Uu i�#0Rf���נx[)~V�g�=f��]��W��2Z-�o�P�𛹐y�R�I�0#��^٬B(nEI�@Sm�T�]:vZ�E�s��}/��V�ȣ�* ��g����9�Ryr7}�y#�d$�;�o%�X�P��0���<E��K�=V��� ��fp)Z�t'�y��� o8��'D�:��x�6�i��O6.I
��ے���m�� ,H����cbߺ��s��,�%��;�܁*�"$e՗�a��݊k��[Pƭ;k��m(�e�;��a%������ �Wj����L�ʜ��X�ag���'�?��n�sh���E�Q����7.�Z���z��s�L��˵#��s�nܿ�<=�����a	7�Y���tCi�2_/�[?�	�,�os)̫��&�}_��+,C����O^�&
'��ӵ����0�^3�z9����B&̽��ۻ���F��9��3�i�%U��m�ad(|{��R@����Gǉ���,�.�ZV7���Ss�?�B��1���r)���H�>�G4�L��]�������S-�w\��Y��gXl@���ڱ��ك��M4��$`���˒�a�:8@���/�KE�*"�ZYD�xv��/��<bu<¬Q�oǣ�����	�*�_��W� h4��F�j�*���V3Bf���M�={Trծ���d��g���(�l0�!�&KX=�Gg�l���c����m�~T�4�i��'ϿK��K!�;^�m�������(�ֳ�)>/�&!R�%L޽ES�Q[���������O�د�]��XS�]�X�ɺXo���W���8��W���/җ�)���p,O(J�?�	�\	i��8&�W�kZ���4�	�W��'����vTu�@�e=��O���
��������]�����V����9S��~�=��5����z��uX�G�קwPZ���G9O��E6�|��%m`!�ĩ[Н�Р9�	�,l���] ���<�O��ʏ�ě��ߛ�R��g�!�V|��S����w�l��	�9+�wR; Ť�t��z֙;Z������+�t�:�7������4�}�*�%��Y��S���~��G����Q����/��-B�I�ޙ���-���ؖ]��0�[	S�Y��l"w'�g󒓨}����_�U��{Gw��_��l睝ʢk��a����;ҡ<�Z]�̅ک#L����ʌ+�M��?�FW}���Ν�Υ��wNԯ���}���)|�й6�0"�,�LY��)M61���b*?Z�a��捂BҤC��)�^�om���7�:�r���2x�y)cs�㤈��@�"YO�7��	jz�&�M������0���i�K�MQ�i��e�Sbyk�j��k��X� 1��X�k#zई���2�_^�2���3�7yWO��I�8�_̭j0����C�ͨ*L�"�O��k��ǧ��>'��{���q-��_QnBF�ь0�'�!'^�!܈'8Z�h$��C�!qAw	Ǽl^I���8�6�c�'F�0k�������ԮWWuWu�<5H}r��tW�c׮]���yX  '� W�2��bJ��uV���c�(=�8� :���'}$Y�IU���Kg��7���fIS"i����)����-�q�0��;�Ky�:s֣��QN�(�h�9E=	eB G����i��BZ�s!�����,�x�Βj�T�\JUJpH̔"�M
�T-��E��p	�F���9�9�05Ka����3�~&��<{���䣣q�h�/ۡ�i��tT��r���\��S��fz����:�S4��H@��,�tI�I�H��5�*=U�"v+P/����\����ͤ��n��&�I3�j��P�%<|{����n~��ͥ��ᡡ�a:���G	����Q��(a��?J�%��G	����Q��(a���%쏲(FY{.��O���$!�cw�v5��ʙG�����E5�#��8���P[�������{��Cs��5M%%��=3v�3����~m�Sڠ�!�-]@����}�#������/����{t6x�����ޫ=]�_�B�{l�o!&9*�IM" �,B��i����U6A*�`~-r�hߊ�AU��<����%���|�Z>�1L�A�|ݠ�2L��/0�yR�Ɩ���^)�`٦�t�[��ѵ&tA��r�n율]�p:�`�SO��8s��pʛ��1x���.�oO���q�9�=�n1Nb��Qt.hň��z��.N��J�(��(��>�n��-�'ɣR[^���Khez��=��	w֢��k��+�?��6uʲ�ު-}%��:��h���{$V�=��@sÎjbJӐ��c��\��l����1`
��o�&d�e�p�����Lk��ѹ�"���3/�Ic���m�(������=���X{t���O�)�C����S�Cm�}����?�?�ľve��}p�9T�}y��EB=:]�!C�"d,B%���������4����޶*M%�S �( mB��U�P0��-L&ܽq���=��|�f2@
��	p+��JԴ����k��� �۽���t�=ۦ-� B��w�X?"�1��
���O�����������A��B�*i5�쇉x7���#�8�VC��O�g�՞ ��?��
�ם���Ÿ����j m�Lt�S��-�\cF=8Zu[;�%�X�%R,���Mh�S�'��"i(��"i(��"i(��6�4�+��SLId��̵�X�A͵�[r�J��g��iFwf��U�/�M���Q�4Yɤ˅l1��x9='�����P���M���	<�D�xi"[(�O�J���R�Z	���X(�k>-]��o(�FtFQ� Ø6H�?F�.�`���� Rŝ"���<�8\c+�/ϖ�U���i�N���_�@%�*B{���⥯|}߾������՛���9���3�����.�d�JM��w��~m��%&����!���8���]�FP�)�C��wAWg<��h_�;�W_�|�R��,���tJ�6�v�=~u���=����ӌ�x�X+�0��e�?Gc�ݼ&+PoBS'b/9��OـE�^��^y��+(s,�9�0���b�
~�3��O���0>��n��Qk�pc�?rc;����龉|�2G����S�f�Et@�t�ׯ��w06�[�܇�(m���^ٞ�%�S	���?��3#�'��H>30es�(�~��y��>�'��uT�t�	�|	�Tɏ��qs�X6�R�@z��R�-�'�(��n�2��B��V-�G�9���[�L��i}�ʱ�Di�R��.x�^�t�J*miEMY�}HH�/�tp�o��ə��5>/�Xn�0�,]3��߾����;��=����[�s���O(uD�����4�8��q��IߒN�w����;i�[h�i����=���؎���T�i|:��<K$|hw�1�F1���EǞ�zV� �~��r] !`�?$̊f���9H�$�ў�o,�>~�����%���J �r<��� 7�g:���핹�Ε�=�@WP <��ƽw�ft��'x�mU���T�a^���w'6@a���#3�C���^ӂwݳ�o������B�Փ�.��݈؍0��3�p��ٍ��B��������G�`n��Zen������O'��t+a�pV�)C���S)+����.��Qz��v݆�d����1;�lRr��M� ��ᔤ��S��4�&-�Y�ᑆ�r�uj��<�w,��t��F�t�p�zE��y�.(2b �w2�az}�0�d`����ڕ��]���啿a_���ř��-)�������qH��N3h�������J���4�
�Fl��gW�moH���R7����o������^'�����0v�Wy����0�k	ffrN��e'U7��sSE��g���<@`���۳�/֖��[�͟]Y��o�B}{��|��tv탻,�ʕoqKH�w�����������+��$�`����>k�'����s�
���}�G���S�����x�k_�> S̥��j9��5d/?Z��5/+Cq��s]��K)*LO�7�y}/f��_��dY�(�^_Cl?;�n���lq��V=E���;�G����&�ƴyXoڲ���j0�������ի���7���۾:S.�������7�Ҕ�L���'�B�kp�V�g�N�@��.�@m���L�u6���a�SI\��Q�����xԫ�\'�$P�B��@s$D�!�Vd��q����
5�R��^�dbh��wV/���e�D:����4�S��K���s�p��tl�g��9�g>&�����Dr�OoSd'fgX��b�'���S����p��e��9�\�T{|�����x��D}g����;�
Q�{9�(Ä]��֥@�&$9�t��(���ˢ~DZ��Jϝ�2��P�G0h��}.hn��4IS������3��ҭ���Dd0���Gh���S��oLT�/^{�詸��k�w�LҤ��X
��p��aP�d���©p��8�N�D�("�#�*�'���2�o����0�o$��H�:� ��|�x�Z"��<+,���7����w�Ю;3�#��Č�Ľ3,��pF�<�曑�c����@�5P�]�����Xr�����2�~6Xr�`[�qq7��IH�m��ыD�rh4���_���=�g�t�e�ճ`�Y\'��܊�#n��܊
�ƹ�{�[�o��6ŭjg�V�Id�܊�0���g��%nE�[�60�p։[1�s-)ד�F�K��*�6�P�/���̵�H�:�c1�n5_QF���r6S-�O�D�l�y���Lݏ��Mcv#3SΣXEĀ��s�w�s�'�J�)	��ņ�'��͑uY5��O�5+�h�~��+.�OnP�r���2�"�1��p�IZT�$.��
�%<_���Fs��T�
��I:/�MC��R*W咏��Qr�A��:(���i��԰���:��z��1ՠM��.��fæ��4��i#MF|f��p�߃��у��o8�TR]����ٝ���۟��|,�I��K+��r.�}6e�N��N|n�U�H'�\�=��:�5&Y�٢Tn�W�D1��EA#�YҐ��F����&2��lJ�d(� �g�׸���o��w��-��!ŋoӒ�����9��A`(A��ԫ���N:
�Anh����!Xݺx�T}5��#G��*3Gw8OR�AdY��ox���=��M�A�^�h�~6Y͖�Y�M�I0�������|�z<��%�rg�;��.���6a��8N/�С��Tʧq,�ߖ��m1|R%*�v�09G�*������W��X�J�s�t��O���k�Ҭ���_>�c�~�Y��k4�|���V9���^8�}w�Ƨ�u\�<�^�E�Lg�����˥�(�+xk0Q�Ȏqe�r�ꐖ�Tx%<�L��eM���-��^A�0~mO�0Re�����.n��{$q˭��d"�����<Xϳ�]r�b�0dÙ�f>��<:��6b�(ñ|��l�O�M"883�B���g'��P%֏N%���왇�tEq(����2��ꆤ���­է�y&��߁�`�`0����UJ���J�?>��@�cq�/��r��!�Ql�O��PF<��V13�Ә����w;`0�r	EĵCB߸��1���Q��)�'qs�yq���8�벿�΀���R��@˽��l&P°��!�fBI6�\@�I�0ie��'͸�n:���@#��?8�/�6�"a�W��H�D�H�D�HH���i������r�lp]]>y4]�K�K\�����\ ����կ�����?hRM�u�2��S��5�;��{k�7�]\�9sZ-W�Z`´id��Y2����|Ӿ� b�51Ԟ��t�cx�nl*�NI��8��g�=�phiw1�n$��XR{rG���On����c�����%W�0�x!rz�d�kሿ�q�z��Bo���2_� ��4������� ����/A$!��Lqb��Usũ!�4�'hX&p{Zy�&��<�_ѮONXyH�j�^������H�s�.E�-��>"{��Dz��y�	9oJ�D�~���N�yː?������~���)���RZ�&	�s#>��>w1��x�4�b�B0��	����t��b�V,���~⏙b��3�q��"��<�F��������b3�9<��c�>06�"`�����������������˃:9CV��k���^L�D�L
��z߁7~Gs?��4�O%�A|����r&�F�(X��z�˥����jfz��-L�����8�%�e�4;��o���xt׮��T��4�'S�����t1��mɟ'��IF_��v���-��E<��.Ք��V|t��X�\f+-L�=[���T�di�iǙ*OgZ	���
��*��D�8��U�H���Ԩ�R��o2_�MA/��ty.v"W���+��s2��ON�2�ʥB��M�SW�#x�^H�Fl��$:�l��aP���f�	�4�OY'�Q+iZ��o?h�'&�oilhB�/[x�GދY���0���9��J�TK�G1��Q��0[������_�1�+�K�	���|�q�mg��59���K������뚭8�b/ز\C�Y���k��$�KVq�k��a�eO�V����%�˖�өd��������;����T���w�����o>�F�����������t)212���itx&�hqQF�� ��1�Qm����..�����G_�~vv���7J���� ^�(�>
�Q��A`nG�r@��)�g���{m����;��żܱ������E�S�>�����\o��IOgEH.π'���q�p|�������S���L�߻8�P}�Fa��|�c���%U~k�Y�x��b�j��%�^�W�SZ�L�m��qr_9D�R�k��|�F�<��I$�e��@�M��4h�N�/{B�֚������s8cَ/�}z.�!u\C8#PJ@���+3�r�A��\vJ�;S������_q�zqF7���!w䚅��t�	
�I8*/��?��ض%S �ZB	P�"`�E�C�k��yK��f=��M�rv����?�	�g9�Y�Ud�M���0����08�0�/��$�Z�q�]���f���gio\�@,�S:Gdtxt�tIU�ey��M�|�m
�!xV���8x0�W\��)��t�[�T����ſ��2g)�LH�F%��<P�U�
Qp�LU�Z�u\bk�nv3>�[1V7�������=��L����k?Hte1,q5�v���[��c�,}����E�x=����W+@Q�� J!�=$^��ɛ��̍ut(@�>9�u#@�*���@ي�	e6����Ae�T�6�_�tr
�'����e��{Q�,Y�h<�Ȟ�V:a�p��j�͞Ђ�	� ��)A��D���$7MvL�u\j�*��{�����$�0X6(��>�F3�����/t���.��tf��#������or[,Ya��V��!+�I�{Z�$����{�r�H��S��SB��-(Z�����������={�������瘽�� �!�cl��h�O���/\�r�����/�THr�7����јvn_�������{P���}�ؾvE��]֖�_[����:,;�j#H'�R~�v�F��p����v�s�t���0#'��	s=�0��]�S��|*7�ӤΡ�q�s=~u�7��'Pq�s9�U2�^�yRw:�OI��"���'2�|"#����D
q�)�Ȧ� iG����\>��J���1���)T�CF;d����!�%r�\?wH�N��;�w~��R^���W��X��5`�Vۺ-P�J�zǭ'dz�l]a�� aF�lm2�3�)tYo� �F��h���2/�6��o /W��+m���h��NVb%�$>^-1L1/��6WTqR���d6v���Fg�$\�!�`n��-����A�2��_"�E�d�~VBH��z�jx ��a)�����w�}�`���oJzߏ�3�� {6�Aj�5(�0�jߜ$�Ǎ,�Լ�9ӥ���+��.�D7���濩��c�gC�mU6F�ǏFw)r m��kA�>��_��M�>	%b��e��u�9#Џ���@;�	�&��
����*�_��b8���졡̸�k�E��<��=fP����J�rt�?�>����+[큄m�e�z�41z���"��ߢ�?�6�T^I�vz����)��.ߐ�\��܂ɓ���{d*[���ť\ʧ23Gs6�g13���,pH�\LWs'��܊i��59�l'Oﰄ���U�>�/ʹt������PU::YIU��t!]�Ȗ���0;������h���۞+�-Φn����V2�����Ȟ��q�З2�+��~0.�~̸�{��7���0C�c1�礐�q�Va�s��<R�y6���Y�0w����y�����זƎ��a��/M�K��_c�VE��V����Xpo�ֻ{�x�����{Y��.A'�%rC���hJ�:�M:;|����߲i��6{��c����谑	o7#�3NY#�ivB嗝�hy�eH���¿=�YԌ	��[0�s`I"P"6$�'Zۆ�ب����N�K��aL^������Ĩ�:/�p�����\�>�9�A��G��f�g+����\
�C�<�^���	^�߲���(�iÐ.�2Y �I�/m�W�"Mޥ��[�RZp�� ��^[�BKqC\��C��u,�����}�wђ�n�n
�� ^:��J�N�n�r�X!�D?G��Δ��X�	�e)�;�]R�^�푥��q���"/��Qu~\n�9@���!���8(�K�;h�V�t.���_m�T��ѕDo)��@2�bQ�)�"�r�|���sl�A������֣f���0j�M	5aT��qǢ��Jj��*I�*��a ��j�RU��>~]�n������Mcy��X޳���!M�K�.+,�|01<6`c�p�hĚ��W��-�)9(����#54/�ΰ[0c:E-%��Z��?C��v��|��s��v�����J��#h"l�Ǫ�<�LJY�J9���r6N�2��UhE��Ȕ�ҝM�l�ݷ����p2;�Oώ���J,��������4�F�e�L�͛D�1k�8�8����h������x�]�D��_":�l�8��X[�^Mc~e�H�M��w.�^!]��I*(���9&�}�R�� ��<�^:��I��J�S��Ř'��x���U�+OJ��}*M�0��(��KgW���=�^-ͭ}�1�p����o����;��]{��ڟ�_�|hh�U]��
��Z]�O��y�p\6� [|��M��;e�o�m�#�����e��E[}'��M�����M��c�oԆ�6n�Iy��.���v�l��b�９����Θ��&�����ٯ&\ Zwh`�� A.���\��=@�"Ѐ�@�\¸t�e��m@�\7@�C����h�_ ������1R���l>]�#ڜp��}
���u��1hxMG��T`ƨ��ƺ��c���� �o��}�@�{�Y�����Y�E��=�(�n��z\�%W=m��&P����-\
*���+X��ݕ�p.[#�p��T�0��_\�߾ȵ�TēU�+�?�_�f/^�߿1�h݁�;��_?�$�����;��9kK�xl�~�D��xyO���8�x�XĄ��>�k�p��Xph3�� I� I��c�[� ȇZ[�Z��hAS��S���tyT��kEf��2�ɼ�A�dP݃�:٣�ɹ_�O6a�lKꮁ/�mɟ'����>l��Ȁ-�M�=]�_OF����PDǊ0�7���oc� �"��,x�+D�$6q%����0������r<��	�p񨰹t[��	+��.����'�h�	(06�[�{�E
��=�4�2��J�Um�W+�m���<Щ�A�W!hkr���N��)�x�*0C9�^�a��t%�F��PѠc���[>��P�����T=�W>���Z7yY�^24C=��Ek���h_���6��2&�_;Ъ�P(Sb���ͱn8N5O��.�'�|A(u����ÈҔV��W������X���Y�t�z�F�B�8��:!-������P��vbP�J��ۋV��z�mٸ;��(�Ӎh7B�\N�Je�X����_�k�������޸l�dH0(�=^[��i�˗h�c��m�wm��͇�:_i�޴@�6���V�N@	n�O�������'��_Ӻ��ٓ�h�ޕ��e{��������z�l�a�H�pZ5���ss��1�yx�Z߲6z�v�{��γ��σ�}	��4��@wZp_K]��ծe��j�K!5�[6>'�֭�9���xB�\���� Z��`߾g/�ܽ��o{у��n" k�|D�l��a���[^xm�~�46�S�C���o����D1�}�6����}ܣ}���[[~��� �c��0cC:3-m�|0:�~X�*��4f��aKZM�������O{^<o]�AA��ۡ\.S��L/��u����y���:;a�w�y3<�u����уG���w�Q*���N��Z0�hK8Ǆ&���*��wj��5M{�󤽐Z� �)��������[�T�.g'ssxK<�:�dY���S�ĩ�T�% �<�?�PU�;�Qb�ũ�1�r����ox ��?����U�ȥ/�^N�۷#�]��`n01�r���/^B�As���<ڷ/ۥiٟ�+�@��x	r��
����ذ��S,�_�{��O��!�o.�)ܔ��4�� ���,(r�O�n+8�C��_,�h׾X��(�������X�E��MO ���'͢��CxȺ�rȋ�b9��X�Յ3݊����74��0N�?�!���"�f
���؜���Wh�7Onbǳ��b��>�Р�Q�Ee�LGY6��(���M'�,B
BE�h�hl�D��F�����Y�F�Q|E_�D�]��P��(����+��ջ�޹�#�",��0c�l���!��7F�W��Xo��]ۼ�mҪ��3,A��=�{J��{���o �s#���
�g�빍h�+n���ݝӵ�����g�w�ԖjK_uݩ3�l�CP5η�WPX���W�ξxyey��cp~����6��if)��\E�*�N�	�"kJ�¸�	:�q�2ZE��s��5���B,��Bzy��U�
7�ﾚA�?�&p��3��ܸwb�N>t�W2~w3�F倣r�Q9�@h�B�<�Q���./��5�D��'j2��[������q�P�aH�i��ƕl�����+�-�g��8�ՠ\(hށ�����2��c�<8�=i���_��f�=Iޜ�G�_�J�}p�ځ?>���+�'����*&GW��j��,E*a�y?��pU�r�D�0�bޜ�da��E,�b�ؾ{�����~��B�C����~�W�?X[�X�oT�B���2��H�'�?@B�KV��0�/�60Cv�ә➢(.f��3�b&��L<50:��(5�.�������~e��}�[Z��]�)͖��-WK�Gv�񪪺f��,l��}��'[��4ڨ\J��x���b^� /μ�(�߾����9�n5�)��OmMNU�C���K�Q��e�7����~�[GG�z�^�9�fPa�0nA�w̎��/TJ���T�&wW�W܊�˗u�����J,�����ODPu(�{���~���L9�8�"�F>�-�&s�4�T�Lc8��t�+MgŃ���X9�O������Hc�R�h��
��kܻT����bx�|,Ä�w����$Ӻ {a�6L�)-RU�{6еS�Mmz�BgGv'�;���AE�ذ�8�{x���YO�l<J6ބ3,�*r��b#���!6J89�nԄ��\�%��Q�����/>v4%���ne�m���W��Q���Mq!d��<��m\�����Y�v�2׳1�QPm��"=B�G���!
���5�6����Zi�=�G�rp�:��=�j�㳫OX�m,�B�a�qu
��*����B��iz�E��r���-y:q��H��(�7/�{�j�~�m;Dw�׽4�m`��$e�d��v���:vB=H��O[�|̂��|m�؋t��-�>1:l7
7��Z�~�PS�5���QB�1ڱ��o��wj����$h���H�`ρ�D G�#�!�m�wr�O��N���w:hJ�S����XJ��Q?��P.�����BDJ� �G�5#â����:�7�h��ܜ^��{%+�������Δ����5���p�ʨ,���T��=��w!Tj���p�	��`:�	}ӤE��_����(Q�>���=��Ʉ�P�%�[d�}�g�B%�}:~$�<0R,�־S$�ֶ�s�R��n�$�q8�7��,�d�!��a >0l���%�	5d�5�O�P�IN|/u"��y���C5��r�J�� S�ݻ0�=�ew��$�8S1ǁf�T�92�i,[��$��e��k�]I/7ѭ'���{?üwa�,�E\'Hd;\U�ڙ��be@�8m��%ē}��IX��w�5�
	�ԧ�@�~����t������	7I6�M� �?z)����8��=D�o��k�V�83� �����o���k,�	�F�f������2Yg��O��#�!{��!���'��yZ�O�O�]�T�2'�QZh����0���>I����b�^.
E��E���,)�E�G��ݼ >���%��E�5���pF	�D����\��l+`�8Ə->q��lqf�@�ݻ��_������~{0���Aw�"?]�v��O��_�2���<�e�$���;��$���v�11 0̜����(��H�&'>N��I�ǥ���L�|��j���cy�R����	�?LJ"�Iχr}�ب�Y&R�X�/��I�ˤ���&���G
���+�T�i/�VIW+�f�d"@e�L��#L�\;{y���!����������Ľj�z��R��&;K����o��F:p��@���}[[ZX��� R*��-u��oz�8G�8T��{��o�a	Q�䚤�`��u�ÏkK�W��ƛ�U�֚j.J���NI���#���v�t.h���P������VB_�����^\F��¡��!���3��y��E_�fH���0Q<v��+�iGџ�;��g��v�T��
X��������!��&�i\��8m��b�n|�ч�]��iS_��Z�>i���OG
)C�
usd��橰(sR���ړ�?._H� ~Z,F0�a7j��|q��rC[T�c�\ʯC�؋G��{˻p���_��ՙr��N��ɗI	}����x��MļYқp������_H�S�F�z,��B�P�����!���1����-�S^b�d�g�'��,k$!R��.Ӕ���l(�+)M�&O21b�������w��X�.����&j3����J5[Υ���%-�q|���<��wI�I]��E>���p�3(o��TΠ�9ǆ8�J0���������u�F����4{��7�h�)�ʧ~�Wc{��}������ǅ�7u}xhm��������q}�O�}�>A|�^�������t�~�!|��n~��3X�8 ���Bz����tV[�f/�����^b�ɾ��o���_p2j�?�r�LPs�K-�"�W�B3��g���rD����-��^8�vУ~�|����Fd[�H�m�0��0�c�aN'H�M~<Gߋr��7'wLe��2�`
 X��j|6W=�`�S��Q��v"e�v
ۃ�O�(ax��)��O�>��0��D��-�HH�D"Y�S������w�)ʌ�:S�%|,y��{���g���؟��AT��nC��YK�#ɸZ��-�|{��>�{��_kK�$�}u�}�>��՟��۽�z/C�E�&���ݿ0���?��ܿj{	1@���*�E�a� +l8��"`FRS$5ERS$5����4R�W �I��ZA��)�W��üշ#3SΣ��Qo
K?3GI��o�1�-�.�+b^>���ӳq��@��,��P�؀�~��c�}P.�|LHlRܵ�ۣȼ^fs���9Ӫ0B>����Od��)�ȁ� ����W�c��!�f�N<A�����T���9N�u��<�	�s)O��%q$��Gq�	z�%��g0���l�Rk����alR�m����+�s}?b5͜W�8��i�k
�����f<����UPlњ_�Z)t�Ɓ����UI�t7Ui�#�+�b0{6]��������j�:S�|,��������QBu���I�2[U�X6s���s��õ�W��E���%�����>S�$���{x��ۏzA��|<Bn���ɇ#��t]ڧ-FԶ#Rۑ�h�V	�j��J<���Kf?�D�l:���S�^�̳��T���`/^\��,��⊍��p�>�]퇏V�uӾt��%���?[��l|u�<�8�Ht�7���
���C�����w�b��ڣ?�o�KX�.����L�#��ީ�O�b?�������{b �O�0��Y���]m��ң��؅���(����}�R�����0㽺pvt��I�1r�@���ٽ����G�v�O��~zi����g,�RQ:E���@��wT-�o�]��>w���N��h_&��S��(:A�D�Ȗ�&������G}�^�*��91�'΁f8����~�=��+�����o/�׮��w,��U���@��]X��?��$*I�`�l���Q���wn�o���>��5	�JϻH=�=1�ID'z�N��[S��:|��_.;A��Y}XJ'R�8���Mt����I�y�c�>iQn�K.�3������v��t/*����/F�ǀ@ 