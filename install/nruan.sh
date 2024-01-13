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
�ͩ�enruan.sh �=kwE���+*�Yq���$숝!�]�B�f�p,�N[j˝H�B���{�#O�B2@ d� �.0y�s���%+��/�Wwuw�,;�fl��]�[U���ڦM��6�;S}%�j7�����|���Q7t�X��������D(R���ɂ1��%izլL��JC���ÿ��e�q�O~Z�ҫ��@���ih8��eg�;�K�e����-�5�e�5��)�td 5�G�M�U�H���tZ�.�U:d��ԭ�3�YAs����p«���(r�� ?O��!���:;�e#�\6]Ӷ�*���WZب:�T�U�fO�z�U��r�n�M�����h�P�1�T=F1�@� �lLkV�ZEC�l�y�j��+W9=�/�f�@�\m®�%�j눗]�Pډ��C��. �(5���Ѩ���u����]F���#B�r�MVun'�����1�R�Y6���f���I:��)a:�%�ne:u	��+MBss�0'�>�h�t�����<.M�8�V��I,Ѧ�׌<�D����_-��e*��U�q��s:Ut͚�.��	X�'���݇m�:�t	��3�?G�"Vl�Q����c��M3�'�mcfd>��<�kϞ���f����)Ӂyk�ܪ�V�A�M��$�[��&��f��l����4�?����Pj6�@�/ <�ugD����a�3%����w��D
�\�rMF�QT�L�6&m�E$G�9��ϣ�J��<�7L��!��Lu���(]�
`4�������t���J8jRCa�*�h
�� �_ԁ}+V��&��b�i���D~�������l(u��bXF��z��@���
K/�t%���uov~��u������/^m��оt��ǳ��_-��o��s�o<<y~1톨�a�	�20`�s��ܗO�xL�FQ��HG��G�@�}�U���h���H�Q�R)����H�D/U�-�YeөW����+M�ЀA����!�8���u�֝���}x�X����+�s�߱�%��5]��z4Ԅe(� 2լ�V������,�@�:p�p@E^-�t�FѴ&�I&�(�"9�Bٮ��L`,�5��"H�"��M���u`��@ )��8�\��V���Ŀ��<�D�@���ӹ��SN�Q�;���n��R�`	2�g_��/_ ���kg�n[���.��r�/w e���O�����rf����f��hW����ۉ�`n�T��%�(D�\:4:׉�������B��+��a����M�DxXɿJ�U�g����U�*xt��s�i՛n/�(�>R*��"���"���+�\E�b�ŻL�nx⣂ax�Ɔ"#m�����oZg�f�P���	���P,)smc8(���]0���1Hi�0I�Y{v��ݰ��h����'�bF�	�R��A��mT2#h�{��4��ٗ-�`�$�W6��#ȸ��F�¬�}	V����ps^?��{�G�r4�ċ�)�)�GY0�о@xOeV1��X�`ޏ�-��h�ݓ����4���>������;��
F��c\�5Fo+�s��k�yz�A���Y�;��k7�v�H��M��AcF$𔗫e?E���;�^���@&�Cb>$L�F���@HD�Ā(��ї[�0���D9Y ��QR�����Kw��=�����[�|�t�.sI2���c���~̍�����o���6�*ۧ.����Lg�ޮMg���F/JS��O�j��; ��/���&��C�pES̓��}��3&H'��$��
��� ���6���R�Fs顡T��<��c[��G2RN��p��ם�[g>o��>���w[�ϵo�%)�|NLm��{��.0�a?�m��������;�� O��;�Ǯ�1��h� �W�]��K?��-ݿ�hUN����8F$c��։��o3�
��ŏ:�����CO�)�����{	XU��	^���v���l�'h�dzan�e��+��A$µ}��k�-�C�4r��5bQi"�u�4��c[�ŗ>��"Tu3=�Ϫ��l� Y�i�Vo���Ƥެ�g�G(��<,a���d0�%�m�(E��z�)��1lEP��W�@��$��A�QRæ5ڶ�`m�f7]���zRI"bq�~%1 �#���>�{<N�#_9�F���Á�nb�����֙�؇�75Ý��T��z�5y���P6m�d�nW�r���\HT���[uҍzc6=m��Ao1�ü�u��bAn�2]�I&b�tY����Ƞ �2+E,Md��&7����l4�VIn��I�\��n��!W� F�<�O4N=
B��4���l$(��\*%fkoRGe��V-�E��1Re���Vt�@��Çw4� �,�cQOEWl�+��2_�ڵ���m�X";>8�L���(�q�U�b�ch������D�@��@�DK��
D�CH��L�C�2�h��=ǘP�R/0�v�係EF��tM�N��?>h"���Q�E���< �`��L����
I�?C�j��»3�i���x�С��k/���1m@~v!�hd�,�+[Q���fk�+ u�a�"P���؍u��L�e{ƱKGh���Paqp��e�0� �3��9��s8�*��@�{��g6�c#�z�h��'�3�ϩ $�K` �"+��>e�2�d���3�\Wsܟɼ�����ސ�@��\�#�O�a��G�F�R�B��A�m��JxG���nNm4�ȧW�7�TL���h�k*�k��1�%�g�-HBDé�8�qQ�ʱ�(b�E6X��kA�_Z��y�#�~�gtTA�L���e��p��ZΔȑ���cH@SX�k�H���$Ǵ��=�}�j8zI`���h������*�'�����~�#¼1�� �(y���rf�pJz��?-���b�'m��m�
��Z%�c����M;b��V.5fGP!�B��}a�6�Օ�m*b�2�K�mo�.I�f/�J{���X��d��<W�����QA<���Vi0w�q�f�-+s"�1�¾}�B� (���b�NpE$���ؙ%�q�`X%�l��a[*��u�1�S�������4�{��<�Q�C+�"|�����r�=�`�	^<�V(�x��/^n���[?/���Ň�xN���y��{�1�^�ԋ-/����s��z������C 6ދ�4����G1�O��wAĖ�J/~3�jˋ��ⷼ�-/�Ћ���{������~��/v{^<�Ӱ���]]7p�g��dK�0�#1�M	ȍux��/@��ܘ ���Մ	-���9e f
�0 I����
9&a��#��K���*����N �<� $����JĹ��qalO����~� �A�Y�_�P�u�=C��u�ܦY�L�{��j��A��=Yk�V�������ɏ���u�6�����x'?��8�/j�J7������8�,|JUA��%�x�a30��Q��gԵ_Ԩ�H|�Q30��Q��|M��Ә{��%O2�"�=���_`�؈�֐�mbP#�olL��8��@wLC�G��F�rH#�}�Јn'��;ˮ_��VGW��kb>r��B�#XvHȥ��n�����Z��E4кy������~�:D��!�h��{�/.��Sx�8�� 7�{
�K@�>�x�7f�[��^c�3!�5mʐ��֟�-}���)�ě�ō#�%�|E'։#ӽqd����b�TE>���|w��r�s��H�B�� w&L���D�D�0G���ey,���pd2�L�w�����m2{�	�@�u��GP^
Y���l5�
��֮�-嵥���ז�zR��B_�X,�2)������U)�If�,9Y�ғV���X6�����M�����i�u�j^sC	�%��4|��|�{�K�[Z�9*\���j�$����
G��#Hu�m`2�-����_���{_F�I��ޣ����<���6�爦U�4R��>w�",w2!�S��D�Xx�ɫ��Boũ.��8͉m ���߻"���R�N��\�P���o�ۍS�H[��(1�ϖ�&)�Xã!�"x�;�>_	�&8��X	}�l�S� ͗�bI�/]���.��2�g�M����R1�Y3tkp�J
2i%��Z�&��l��n�0moef�yo2�-��p��ȶ;`�'�Rjg��pӫ�]m֬�Yv���*�8�A�\n<��<�N"b�E��0�(N_��ԫ������}��)�A�K�71�43|XV`iDH�@QP2�����rj���<��y$2WG�C��J!򨽻Y& =撜x��R�����I���ӋXU���_��o�:rv��i ���ި�^�r��d�	��\�E��m��XX�&t�F@�*-�id�ȼ����鸆U$0�jt|��n�܍�n�_><~n����|Kq��:����v�ٍ���7�5D�p�!��#_iخ��#�=��={�A0�2!�5�
�O����w��K�k��w3�L/�/�"�OB�r�A�э���H$�BĲT���[�yf�UERVXॷ&��7�F�}�$�����Q�9i�L�ʰH�0,��Cu�&a��2@����c;W�#U����ܑ�q����`�ΐ}G�א������`���P`[���D/�!v;�8\��P��+��|;&ucu�+�1�d[|��
H�X,�z�ŘI��x�u������6���zl;8M�.�t)�&Tx�~�����74tˡ�*)�rh0�s�K�#`.38���%����ۛ����1����Z���b�Q�50AÞ���',KF"�=!ʇ�F��*{� ���/1_夰Șu�4�6�PŐ��.mԅ��Z�1�RCO�F�1�P��`CC�?ɟ�ϖ��>�*���D"�5ƭ�'����n��1�TN:�M(�;���{]��j�Ir~�VY�
Wc��+h�����y6��ZPs�kja=*�m�E���l��tٶ1��y�k�p�y0��I�&[��W��|��m�a��,�SV1֕�F����7�%P�]�(BFJ���TԪBY^�W��XЊkpuf!����7E������Q�X��Hl�)]$��H|�g�o)���擅���X�yf��/�jI�:h�����Kc�%��[�h|��g�)k;2;D�}���`q���������~�J�C��L�T�tè�cd��F�F<�,47l�U���]��C�����0�9�B�!���ϭ+_��?�����On�����󧝟.��'��_�����m_����?�/v~~g��qvd|�؅փw��;���x&�Z�Oq��0�����΃��ݭS'��j������S���o]X\����ݫ�N�cmw�KFѺ����P\��/������k��2������F�� U�KG�
]� s�C3�?�D�P&��$��4]�����=	&�f��6$�I.w�Us�q�i��bLC}�s�R)��5�̙�̞]�N�K��V�=�Z��jkN��W�l�}$D�ث��z���l�	��\�0O�f�}�B��U6^#����V��B�P�����%�_�f51��h��2����;�na�RHA��c����s�s�gD�MOس�^���		�)AՎ�MzQ�t�*H�P�	�Ʈy"A�Zɭ"��C��P#V�ʥD[���k�D�.)5p@�˨�WI/�#�ys[�\��9����[�I���i���M��<�6���k��,�@�wo�f	�P�%��a2�{wf0Gd��w��d'h����օ����Hq�f��7�{ǖ���}�'r��Uc�h9"ˮ��*�z���� $���Z�{�:u�s�k��t�=k�!����gf�f3v��ȝ����f�hv)���	#c�"�T*u�_���҃O�ڋ�[��.0̴O<D�>�|�X�?�?�@����"`�s�G�T#���d�|`�f�ԍ�;'���f��t����>������޾r��󒼞���6L��C�$�l-�33�O��W���y�~�����/;��l��$w�#�7�t�Z�}=&�_�u��LC�g������c2�
a�w��N�D��,�.�t_9�:s����ﲮxtq��Ó�[����h���i�W�fy��7��!6P1�57��L��Ō�}�L��G���޷v7q]��8���,hb��I��Y+��:m�S-!�m]\���q�,'��4%$�@C����;a���#۟�޽�mΙ93�|ÀzI��3��>�����T��}��-mvt��M�I�c߲Y���n䤄�K�g�����`�Oh�;� >yg� ���٫F̚��{�� �Ź�����t�Α��K�=I��3���g������{�s��%��⑫K�
�1X?v�7 ��݅����8c�XV��;�:l��/<���;�Ww�$\�В�4Fn��OƂ���B��D���W� ��ܔԍM�|�Μ�_�q���ҽ�>>�%�GN-��T�S4/�xe��ߍ}�5Կ��p��t\��-�S�L���@h�Z���f����|�)>�S�m�T�U`�C-H�v'���]a�D��S�=Q����;sgNp�95�8;��f�?�'�h+T���|��S�+����Ca~����};��|�2�u�������W���qq��4�(�)�~�x醘�Gh���iLW(������� ���?�k�g��^����=���c�<��ˇrv/\��~�K�
�us��O�A<o�$�%쮑�z	;�R)b�����>��4o���B9�La,-�Y�^�d+2�O̴BD5&nֿ����q�N����Ovmp�zʝ�T��s�,ek�Q;����iO�
�S��{T��ab_P
L�xUX���FC� J����3��l���X̚P4��|��z3o8�6�U|�S�He��f�r1}���D�������(4;`��b�r.G�S4����ޠ���4�k������: :�ğ���w�V\gwH�"� ρ&0HdL�bUa��k��.�c��isc��q)b
}�{E�ݑ��&��[�Һ<�@�	O@��H\+:f�wR�.4C�{|0[MLLLC���DѮ9v9W=<V(�`��ր,]����a�;�����`:�,������Qp�X3�5�ʼ����I峩������Q*X�!j��Jl+׉1"K������O���_$�����*�J����T���x�AϮj<���\/�l�T(�҇��*��
�3n#�Ֆ����Hm O��	��Z����B:��aն!bL�_��]�v��T�Uo��G���W�W��
�*���:m
Zh�h`���0'W��lE6 �Y����m,��ܖ�r ��L�fN�L�1�S�4`��U"���@�Q{��mt�@i' ��Bgo �Ǩ*Hv�HR�։�i�Q������w)	g/A�X��#�v���m��eP{����C�4K�Q�ˎS��/$~hG߳p�T�t${�!�;w��a�	<�U';����AJQG�U�E��7g`�������݂��e�-U���?���Yh9T�.EÃ�E}��G�`�뺟�L6����6�Z�X=db�W�Ws�������?�V��?��,T�b�j�)'������Ct>|#V�^8`5����k�����4*��Nb�~��r�f����a�je�j��\��q��������&["#�D�T�x�:]#��43al/ITȼ� ���5��$q��|�X5���.p�Rr�(# �?��]�Jf�@6}'�̪O��c�[�E.]2���oFPM��3sA��yaꊺ@���C�D�׉w��do�3�L� T3�l���9�)3�li���ã�Θpƌ��B�<@���!�[hB�'d��	ܒ%%&Σ��;fac��ȵvJ�fqdB>���x~�>=K�:��y�u4y�5q��ʑ[�[��Ѻ,��V3횗�܁űk�)P�
x�ѿ2�́ܔ�+�ehX:���A�B�N2L��@˖ �[����]�P7�����������%¯^F��Po|�6��N$�ްB��ݭ(���<g��FK�{��1��e��Vf��_<^���ƒ���-��K�'����U[��j(�㣀�?RBJg:v��B:�X=��q�XtȖ�%N���2�2�Z�a�$ʕڋ6 �N��B>Icv������pKT�T'�<9cݦ`��k<�����2S�����$�� ����s���ܻ��P��x��a�6�5伞�)���� ��v8$Ε���/~>@6;d��:$�!bs,��)v4,uǴd����p�*��C&/r�緤�z�x��?�T�����=w�_�1����XKcL���V�I(�Y��N�
-}�����s��-�<�	��h�jv>S/����J��6�L��o[�����Gl����ƷIxjޛ� ����7t\3��P�#x�����������pJ9�m`����h�^ Խ�"
l۹�N�+w�$t%��{���:,��L:Z]����{_/��ٟq��M��BsB9��2��{�p�q�&�&�qL�8�z퀌��ū�r��ԟo��5OlT�C�CFꨇ�X��_?Ls%pN@{��nn�LgU����ĕk�Lj��k��Z���*�$�	�7���K��`hB�\��M��ojPM+�t&L?mL6Y@�HQĠ>��� �x�8c�/���M�3a��[.䰜�j$�f�d���!+Q CCC��@�,;�&i�걚�+�/�M38�D�O�[A�4�͐���aW��9���B�f��m9��Fp����gòG�Pi���\�R3�p[&%tLp?�޿��_�b��,:N|i��4s@�_��L����T��x!����x�`?f�UJ���3�����u!ٹ�l5[BN���c4\M%v�`R�ju��f
Ƽ����������b�l��o���
c/���Wv�IV���c�Va��c��7��4��‪Л�'A#Q�'�����J�2�YV���һu���_���c�"$���q�"�5;HowEuX�_OF��vv9��hc�E*�4j�pblv-�
���������t��ud�}���ƌ�����)
L��ۮ@� B?c84)�1y�����]��v�|����28��Mg�7�y��7^�Š����P0-�1�_$�Ϩ�ْ��U�uOz���ǖ��e�E�R�d(�,z�b��f��m�|�253PL7}���*���|5��5@���k���CQt�F��36Xˎa��e�ξ�Z8);�?�˹�ب]-�����8��Ƃ��>^S�;
�B�,YZJ�Ŀ"K�0n"G�EY����|���TƤ9>�0sβXV��c��|�6,���f;�T	���L!�O�Y���d��rs��
 [(b��Hkd`�-?<
��޻�P$N�Ӈ�ޖ�a�^�vц&����D��j�$z9���ؤ��TD�n�Lz�������GYY��<mef�$�Mb�$�Mb�$V!�Y$��8IMu0_P���h�䋺���0_0~�)e��t.Z �铠j9��2�m_:�&��Дڙ��_w�U=J}^����L�yE-���xokA������xN� ١!���ٮ���E�z�Ew�aGkܫ�ō��Wq�k�8�>���|��pl�����RU�Ah#%�B����jZf��|�j�j��a��<�g�"�W�ѷia5�6�j&��� �[�h��.7��	��Lp�K:���-��4�uR~��w�TD�*�>g϶���zݯ��ҭ��~Ƽ�dT���h&�*C5�~o$�����Q֛TН��8���,}�9t"	n��m`s�.�s��o��Io��y@����-3z)����!�����J3:�F�K�Чs�|.#�*)���h�g��X����yC��ɥ��P'�{���n0.mj��H;�@L�<F��l��7�tĺh�<Ê�%�	e��5=)�Hw*��ebT��Y��[}��s��Y��%��
��`̟�W*��m�3�2�kŒV�{�&]�g&�bj���̜l����V�/�oL���dic�U/�úÜ`)�y> ,�N�&=�}{����'#���M���md�1�'����̱ؖ�;�t��b����R�|=e�#b�aV]���-��Z�u����j��*�V�����l�JKNf�	�o\��7��}L����#�XV+w�����>�����:�71G���|�2�ܜ�wν���w_ɬMK���ѻ�[_���i�^��ҍ��K�@�� `�c(����B��9�����$އ-s�c-ꙭ����̹��cA�ê]��5=V ���S��sX�j%S#��\�ye�|^���j�}� ��?�,�ÓD�SO ���ko��Z�J���b��XK���0u�;,�eO����h�f���r������c�����X���`��{%$�Y�>�t�NT����;������m��:��I4I-S�Jh��6%xR(ź6)XRy���̓���	9�m�U�x�N�1c�e���I�Oz��/KQ�:7�f�ym'nx�f���gR؅j��"�区c�W;.�B+۝
��S���<���Aئ`T��1��#�\��A����5��0�/���'�*�R�,�tc#�����L�S��M�uF�^��#y˷D��ؤ6�W�]���l����'�K���F��x��	�K/��5}� l�������<��3J���� ��8�RS�+aM�-�b�Z�r���S`����4�G���S��	V�DV� ]��7�wgo�>���`��s��O���� ��r��x�Kc 
� T��8�l�^��?�t ��x��h~�ْ����jDl�O�d��7��L�z�o���ե w2dX���1`�Ǽ�px�R�|�Aʊ���K=t�~�^�z���k������y�=�k�S�h	��x+�����p���s4^͖���%ع]��{���̡7��_����^#�a�m���;��#p8v���e��bI��dᇹ���Kg?]��fr���A���}�g��2P"����:��5� ɣ��W}ٞ�\�����F�E�v��	�O�6ZZ�[>�u"~��	��s�CO�p-�9���U����`���,/�P�P�,�+m�6<o��;p�Ia7�� �)Kb�����P�������'�;_�j�d`�y�h�P��C-"[����S�ŹDf%��ՠ*�����eg���B��t��ڜd� �OEB�����+P�@�k�^��ƠX(+�a���k#?UE�VR%^�����b�!���s7�s��	s��87��*���.˫t�l��jb	x#xa�J��><tڃDb(���7���<K�+,R�"���N''��"�����~�V��!��<��u����/���),V�UH'w�K� U��b}=��dw���B �"�A]��˻_�H:&j�y9 u�?�Ӕ2Eեh8;Q��<6'{X��_#	��z֜�l+`�
�����Y]��f�P��t0ʗ���Y޵��|7��۪� ���6/�'s隆j�Ք��2��&������H(뤸dz��k-e \��m
;d��Rb���hJYM1�J�t�k��'����n��0�P���AxL�h@#�#�kcD]��_w�����+>OE�Ŗ&6���
�la�D	�зчd����%a�}|�C�-����@ƀ��	Ǩ��_i���H��{7��6a��� `�N�V	Y�*N��[[�Ԓ�V�����
w,��"z(mEb<�1i�}��X��ް�5��7�-��xj���7�+/^���|9��2`P?U�0&�����;�u_LN���z�`�%�]xY���R���}��ύ�aL�! �*�߾�f�θ��6�� r����2�}	N�9��2��=���p����>wϜF��KK�^��J`k|
�(�ǆbK	������)��G�2�1�`O�;�np8_-H�>�ZlIV�D��)�������{؄�H�{�Rd�pXx{8)�	X7�+oV�衮O'0 �MքT=!��#a �s�4�+#ThPRQ>:B�]UJ��b�m��O�r�`��>1�!]!�%a$!�w�-��)���k)K51��mZ���@�� *>aĀa]�$�ۙh���JLgZP^��1�[������V�XaE'x(Q[ZjKKmi�--�����Ԗ��.iɔ7�m�mzۆ޶�w��S��Tf"[�T�_�j�P+f��jJ�N.���<ǂV�^<�uh8��,�[���)*y�T��+�jf�R�9MW�˱�n�r��" XVo ��s�=�z4
���Q4/y�"v0�;h�;t��0I��oC#�hf����#�Xpjv9c^�_���T$�%��`��ι3_,��sg�	ߴw�D����Ѽю��dJ���i.э�k� �ܙ���Wِ�>�}{?�MJ��ݺo�G }��J,�V_Å��g�c�R:#���+$jU	&�1ik���(�:�Z�����g�����䭓��|�>�a�Gt��q�n*Y	�h�V��g���x�ɾ��S,fU��Òv��ѿ���H	Ҩ�;�2 ��Ee��������^��f75���������^����l�dԬ
Ɵ�Y��OG}�	#�!1�ߺ�.>�;�ކ,ͯ��;���[R�.��Z��3Y<�W���8�C�zf�����z���`����ν;s�~߉����!J~19�8\�#�y�a��BwD)�<v��J5�B*�t��n}�s�n�ĥ��V:a7�D���o�9��|e©�8!�<G���E-��	�L��^���V, N�����#�L�,���ɐ� V.���?�s�|���'S�Na����.�����y$o&vc�r�/�e� P�9�[�齩�[T������f�(�R���@��;y��IƓ���]���o�W�d�96�f���Ԑ��
�'�w�4��M¬�H^�H�$,���R콻�����$�"�\�"�����|��,�oX˽5�ʢ�:�u�}�{T<�������"��I�u	�y�� ���f���֓fH��!�,zFF���^T(�|��g�����̆�-��6��FcF��7��qn�rk��M� �a�o�ھR�f����i>[ˮ�L�\��G�0��2�T:m5ws��F�K�jT�7�s������H�v�sI��&.I�q`�QRZF�upd�x�r.ke�d�<���95���5t1� ��� 2e�B�e��SS���w�� �p訳�P%fVH��BJ&�_�vϜ��}�=���w_�g�-~�N����)������r*tА=��h�I�du0�ś7(5o}j�i5�N\�;ʶf��&9�л=��,�W�[5\��D=�Z!2h[|Q$2��}��*���(���^��l��4#��Z]� Ig4�Ó��� ����|���I�)O����$p�ϡ�>$�^��2�k�.w�e�de�:|��Q'`���l�γ���D"F d}fk���H��ч�i;VBL�ۇ
5�סݼb��m�l�d9*9�Fl��	M�'�#\I�:��>¯�-�g��vl��V��)$R��E}� X�����j��If�h�DNR���@7��3ⅲ��}w����6�+O�rt*ҟ*/d�*&IR��y��N�q��N3ZQ-�h�J1�&mB�� c�$z�B`�w���*�plL: ff�❲g��cHBե�c��HA�~Ne#� >X]z ��V�&� �&��#h���GKBQĈf�hU�_�����Y�=U
"0��	�u����Z�	�v��(�F+�����]v
�2Z)��4��-�.=��yˬ���*�����}�"C��|��Q�}39E�vqE�e4S�v��oC��D",�n��x�[��?�̽�	&J�Ռ_u�U,vgN�/A�~��0�u�>��1x�ɡ}ς`\����M�uT�7��S�TP��w�ϝܠ�a��-�X�a9|�J�E a'��3���{�N���!�>���r�Mu�%1(��x�/��:S����v���= s+.��lӶ��jR���m�ߌo.�7�#�惜ד7��~)ɜE��8a�@����!�Go�Ͳ���t����c���L�Ik�U��K����_��q�9��cF�����'�����*_�1��ǵ4�_�f$�p^rvf|����dL�q�$��y"wvwK�D�%�����E�����j.8^�P3+-0���1RCfG��ͽN��L&{{�yf
_��5>M��Y�ά�,�XX���\�>����:{3��@\P��R��\������0��h����������1�O���l5111�(�5 c�zx�Y��y�ƴ�9�xCb��]n��%���Mq۱9l^��Ђ��*�w��H7lp�Z��<p�W��s��K/ �L�©	ݑj�ć��+)+�==i���R����	��$ fs��".���7*5N����-��Q�#e��삺������^�2������H$h�r�J ��Gy�v15Fc�ѷ�V!�G�9PZD�Y��i��GT�
�W&	<)���12e��(�-L�,��:�<�8����"~�i�'9�P��E��!�`�� �/��)��(?v��x��q;#�ӫm�̂�������������W�{��T�w0�y<!-R�ޝqgn�t�<��Ig����ʯ^��Bb�D���֌,	h��%��fEb�yϫo�xG�[���lH3Q��aT��Ș"lS�XHo�dD8ߝ�� ��͢m#.b*gљyXC1�D��S�H�,Æ�
>���<��棧�U�)�3bKŀ���c��O��ϔ�K�����`zx����+��ゝ�֢K���E�1�J��7��Á	�ׯ�4�Rc�%��|C7]��#q����vN�j���
��LdG&����C	�dLB��V���Xd-��@���Áe))��}(om��ؾ���wj�v8tgK�8VNc ��ԯ���-4�܂�Rv�u�Y��o�ZK+]m�����e�Y�T���Z�.q�2^ſ��T�r+	�آԹJ�G<X���#z҇��qa�=�p�2��^�ձ���n�mVN��x��X:7Z����n
����g��odĖ�Mb�N8+�*�Q|���q�E�R ����Ak�JY=֘��=V6�����؄F-[0	�Q��r��}�9���Wv�V�e��Q�o�-�@��/�{���bt��6-���?��r��ó���Ou*S�k-ׅx+�5�x��/��|C4�B��b�Iҗ��κ-���=2^n���=�2/[����B����sG���g���	qO\r�ޯ�������R}�]��U����};z��=�o̕����2�"b�f=d��%�FO�,�����}��ő��s��� MJ�C����=�B��{PD �UW��G��7�kCt�!�����^;��_�h ���#֤�_,x�e���ˎq۩8�
�28h�Pb˾��Ж���)�����Ǒ5�U�H)�+���^7��Ш�@��QƄ ��Ү��/Ѫ�M�r�#�� �ȫ�����ЍɈ�e���^�9!�3 �>^�һo�^};|Cx#0��(��8��2��`��p��miK��#;.jеY�1n��x��P;��B��R��:cǋ�S�"�˟�YX��%[����R %Ы�`�Ԍ��H��"�|�y>��&�Y�k�C6`lb������U����ܰ}��,�u댂��4�S9}�(׼�xYV �ߊ��q��� �b�%���)9@�-���d��U��+<000�s}�`Q��l�r�&��l����'��jbD��|rB���S��������e^��T�QmY�6h+�u�1��eO��n�)cg1���@Z��h��cF�{0�Z�'o��<>9ǅc٧Š���٤b��c ���o�9�Ȧ�lZD^[�i)E�O�P$��$ȞХ$�,�keN�ʝ��2���SY�:�m�G}���}�ۀ�"�.�ԄYK�-����l�ظ7�
�e�����e�P�̓���_(=!����K�����/���/>�t��It���������������z#MϿ�ĝ����|l'��������`6,��~�r������ f�p�S����}5�����~��&�@���r�ʴ���l�Z3�41s���'�[��/�;���{��ob���i�~1����[h���>��ќ,h���~�,��A����3������^�-]�X(�����A`ݻ�>��p��UL.sfZ�gN������,Me��3�c�1��s���!���
���G��eٓ�V�+�����x�����N�m��Sx�)��s
^�m�����u�69�z.���u��W��6�(kN�>�b'��;�S���r�n����n�h�}��>�m���v�G������n�h�}��>�m���v�G;�G�w�||���>
g"�u�QAe���>2x�����'�ߋ�vSk{`mX�pO&��]z2�&6/8���b�QAٜ�U��E.$'UW��^�x�����7��T\��������� L1DS��*���{ʚk�>%�KR?�j�\�c3ĭ�>X�����7�5��r�A�QTOT����c�<���]z��ş�B:��-�,m��f�(����ru<[��/����9�45(�z߲�>ne�S�5�B
�L��x����'�T7�+JƇ�R��~��v���{*�*	<�!oH곧�P<ɮ�ͼ�<�&>G!ap48�t0�)D�D��%=�x�J�w�M�W�b�<���U��kruaQZ�Up�b=z��e�7H��3�"�̯�£,�>oS�i�u���Zq��Jn"Ub�T+��LM���-��~��;Z8)k��]��D�������Mo#K��2og�Qc��?���v/���:�H�l3 ��Z#���QsO�RL���r|���b��c����K�����l�p���V��#���mh�E�z��@C��}�b��j!���?z8��FU�;i'[̖��]݂���쁿2c[J�6�|��P�[l��~����M݄�9�;������g��1u����<�x
>�ՙ�J5N�g�����շ�N�FOd"���7mX�eY6�Ѯ����ո/F���F����K�B@�Q'R=~���N�.=��]�m�4�Y|�(�=�-�{%?���6��"ïpD8U��Ue�0���+�z����w�n�f�`-��a�F,
&j��N��6b���\��nS��$ތ�M7������1��ts�����'���VDx�v��j��p:�f�Ǉ�Ȋ��U�ڒ�aH�UPͳ�Fwͫ�ݘR���)��D��ƽ�v��;��}�29�ٮO�/������>�p�j��-,f���q�9��_޹��(�2��M�)xW��k�i ��k����/xuU�e��,�)S��V��%��Bg̯s~#�,��K��:?��ִ6-�L�B�n�B�2�B���оWޯ�>��f�CoL�3������l,�@1���Wl�r���M�Rњ��Ll�۠��Ө�c�h�ң�Ѫ���2l*5^����&��l��*�=cq��2�Ҧ��/#7��_�Y,/.ˋ����P>dY�ү3kF��<65��5�)�y[��z��"���愱ְ�D���ˬ�\/�qݥ�������H �OR�63�k�R���3�����Uۥ?�	>�C$i]�'2�9��*��7Թ7�8P1^��UTW�E�/���Q���P�y��/�UAG2x�߉�i����]����*=X�|�eq��Ey�K�%�/��N���"Ǿg��l1l�� |����&��4w�_��M���#��iM��Չ��X�6*�-D�"��i�n�0�oP���Ԛ�w�_{y�2����דi��ﳇ� �8 �,9��`va����`�T�z����E�Z��d���x��$Q^#]19&, �6vv�IU�E?N5�8��W�kc�5�/�yzso�c���4�R>$�S�r1ul�I�7��˔�eJ�2�(,d�nݲ^f��C�g=W-����V)_+
�Pi�.�����?ؐ@�`1��r��9�Ժ�F�ˆY|����������n�/� ǅ]/����۴��>��p��3s��{�k1c�������w�[L'q���ߩ�5c�^^��ơm�����^��2��K�%|�[AFY�i���f�\0	џ���wdi�݅�W��v����>�#쵇�sG���46��а��DƆ�Ϻ�1����E��G�[��D1���N3���h��M*��l]�I�u�v.�Y�Q�;�e����-}e��Ļ�
T͆j2�"����տi�SJ�@��KH(�B��yk����B�D�-ن��c8� �f���B�S�"F���Z�RV�P-mMLL�R#"u��]\��|})�D�_���{�����$��-IL���ժu\��i)m��o���ϵd1����S�.iI�~F,&8�>?j� 01>�CWs�˧ޛ�?���$M��mȋ���E7>A�/�iծ�W˾v٭Y�O�I�\�܋yy�ǈ]��(`�7�H��W4��H��=ց=*���N-���I����D�ɰ��
1��4�C/�%L��T��Pn���pI.��%��	w<_Sy��P���S*�,��=qu����cg1$CO���x�0}r�&��#7j5��� ~��Јa=mĆ�C�V�S��G��ǧ��c�?��G��̜t`�m�������&�>���_����j�R�iv��>N�ɬ�E~���ŊZ�Z�n�{b{��4؞I#Fiꓕ�m��-5��ƶ��xH�Aylc�����d�A^E5+֕�I�U"�GF@��O��������?�w�B$�b1Q�N$h\5����9v�3�m�_���W+�ZDD.������9>�agЛ��)yovl,����)���AC��';�%��5�~rE������$��_[s��kg�KޥJ�l;D����W�Ibܩ&hnb?t ���	,�`�<�J=��I���������o�p��ЯL����մ4s��|����� ��JG�f��
�\u54��!ێ���_TD�H#a@�n`���b�lu, ��_ϵlm�	|��S��Y@͠ 5y��z�!B=_Vn��XE)�~���љ��|٠?m��򒽿 �'�"h$9rV[�xw#����>�7d߆Q.��~ؿ�Z	֢_oۯ��_��*)Z�7��`S0
Ef�q`���_�"YB3 �3'.�v�ܘ�����sO��J}1�fbq�G!�Hp_�k�32�\� ��ug��+��,����w�V��i��gZ�'Uz�k$>.�.G`�5���}��=�ä��g����Gܙ��K�*�wq������Vak��%$m}]��}����v��,^>�p�f}�˄4󷧗�β)2�����F0�	\ �@���O�_��&wf����:#8��fЀ7�p�����	�$��0����[��`{�dy΋0Y���{���s�}�^���/ ֳ�����#ݓP�^v�@�g��y�e2ŬS�P���g���0���g���7i�:�ٔ���ILY�9�G[/��"�t��:�/�mHe��d��_�jϦ� 