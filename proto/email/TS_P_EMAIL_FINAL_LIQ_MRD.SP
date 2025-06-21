
  CREATE OR REPLACE  PROCEDURE TS_P_EMAIL_FINAL_LIQ_MRD IS
  --
  ----------------------------VERSION 1.01----------------------------------
  --- FECHA       AUTOR         DESCRIPCION
  --- 19/08/2024  CARRIERHOUSE  SE ELIMINA LAS PALABRAS de automoviles del
  ---             RGUERRA       mensaje del cuerpo del paquete, ver 1.01
  --------------------------------------------------------------------------
  ---------------------------- VERSION 1.00 ----------------------------------
  --- Proposito: Emite Email a los involucrados en una liquidacion de EXP.
  --- Creado por : CARRIERHOUSE, RGUERRA, 20/09/2021, ver 1.00
  --------------------------------------------------------------------------
  --
  l_cod_cia       a3001700.cod_cia%type  := trn_k_global.cod_cia;
  l_num_sini      a7000900.num_sini%type;
  l_fec_sini      a7000900.fec_sini%type;
  l_fec_denu_sini a7000900.fec_denu_sini%type;
  l_cod_agt       a7000900.cod_agt%type;
  l_num_poliza    a7000900.num_poliza%type;
  l_cod_ramo      a7000900.cod_ramo%type;
  l_cod_mon       a7000900.cod_mon%type;
  l_num_spto      a7000900.num_spto%type;
  l_num_apli      a7000900.num_apli%type;
  l_tip_docum_tom a7000900.tip_docum_tomador%type;
  l_cod_docum_tom a7000900.cod_docum_tomador%type;
  l_cod_act_tom   a1001332.cod_act_tercero%type;
  l_tip_docum_ase a7000900.tip_docum_aseg%type;
  l_cod_docum_ase a7000900.cod_docum_aseg%type;
  l_cod_act_ase   a1001332.cod_act_tercero%type;
  l_num_spto_apli a7000900.num_spto_apli%type;
  l_num_exp       a7001000.num_exp%type;
  l_num_liq       a3001700.num_liq%type  := trn_k_global.devuelve('NUM_LIQ');
  --
  l_tip_docum_agt a1001332.tip_docum%type;
  l_cod_docum_agt a1001332.cod_docum%type;
  l_cod_act_agt   a1001332.cod_act_tercero%type;
  --
  l_tip_docum_benef  a3001700.tip_docum%type;
  l_cod_docum_benef  a3001700.cod_docum%type;
  --
  l_msg              varchar2(8000);
  l_tomador          varchar2(128);
  l_asegurado        varchar2(128);
  l_productor        varchar2(128);
  --
  -- emails involucrados
  l_email_beneficiario VARCHAR2(128);
  l_email_tramitador   VARCHAR2(128);
  l_cod_tramitador     a7001000.cod_tramitador%TYPE;
  --
  -- permite cargar los datos de la liquidacion
  PROCEDURE p_lee_liquidacion IS
  BEGIN
    --
    ts_k_a3001700_trn.p_lee_liq(
      p_cod_cia => l_cod_cia,
      p_num_liq => l_num_liq
    );
    --
    l_num_sini := ts_k_a3001700_trn.f_num_sini;
    l_num_exp  := ts_k_a3001700_trn.f_num_exp;
    --
  END p_lee_liquidacion;
  --
  -- permite cargar los datos del expediente
  PROCEDURE p_lee_expediente IS
  BEGIN
    --
    ts_k_a7001000.p_lee_a7001000(
      p_cod_cia  => l_cod_cia,
      p_num_sini => l_num_sini,
      p_num_exp  => l_num_exp
    );
    --
    l_cod_tramitador := ts_k_a7001000.f_cod_tramitador;
    --
  END p_lee_expediente;
  --
  -- permite cargar los datos del siniestro
  PROCEDURE p_lee_siniestro IS
  BEGIN
    --
    ts_k_a7000900.p_lee_a7000900(
      p_cod_cia  => l_cod_cia,
      p_num_sini => l_num_sini
    );
    --
    l_cod_agt       := ts_k_a7000900.f_cod_agt;
    l_fec_sini      := ts_k_a7000900.f_fec_sini;
    l_fec_denu_sini := ts_k_a7000900.f_fec_denu_sini;
    l_cod_mon       := ts_k_a7000900.f_cod_mon;
    l_cod_ramo      := ts_k_a7000900.f_cod_ramo;
    l_num_poliza    := ts_k_a7000900.f_num_poliza;
    l_num_spto      := ts_k_a7000900.f_num_spto;
    l_num_apli      := ts_k_a7000900.f_num_apli;
    l_num_spto_apli := ts_k_a7000900.f_num_spto_apli;
    l_tip_docum_tom := ts_k_a7000900.f_tip_docum_tomador;
    l_cod_docum_tom := ts_k_a7000900.f_cod_docum_tomador;
    l_tip_docum_ase := ts_k_a7000900.f_tip_docum_aseg;
    l_cod_docum_ase := ts_k_a7000900.f_cod_docum_aseg;
    --
    -- datos del agente
    dc_k_a1001332.p_lee(
      p_cod_cia     => l_cod_cia,
      p_cod_agt     => l_cod_agt,
      p_fec_validez => l_fec_sini
    );
    --
    l_tip_docum_agt := dc_k_a1001332.f_tip_docum;
    l_cod_docum_agt := dc_k_a1001332.f_cod_docum;
    l_cod_act_agt   := dc_k_a1001332.f_cod_act_tercero;
    --
    -- datos del ramo
    dc_k_a1001800.p_lee(
      p_cod_cia   => l_cod_cia,
      p_cod_ramo  => l_cod_ramo
    );
    --
    -- datos de la moneda del siniestro
    dc_k_a1000400.p_lee( p_cod_mon => l_cod_mon );
    --
  END p_lee_siniestro;
  --
  -- permite cargar los datos de la poliza involucrada en el siniestro
  PROCEDURE p_lee_poliza IS
  BEGIN
    --
    em_k_a2000030.p_lee(
      p_cod_cia       => l_cod_cia,
      p_num_poliza    => l_num_poliza,
      p_num_spto      => l_num_spto,
      p_num_apli      => l_num_apli,
      p_num_spto_apli => l_num_spto_apli
    );
    --
  END p_lee_poliza;
  --
  -- devuelve el nombre del tercero asociado al siniestro
  FUNCTION f_nom_tercero( p_cod_cia         a1001390.cod_cia%type,
                          p_tip_docum       a1001390.tip_docum%type,
                          p_cod_docum       a1001390.cod_docum%type,
                          p_cod_act_tercero IN OUT a1001390.cod_act_tercero%type,
                          p_tipo            VARCHAR2
                        ) RETURN VARCHAR2 IS
    --
    l_txt_tercero       VARCHAR2(512);
    l_ape1_tercero      v1001390.ape1_tercero%type;
    l_ape2_tercero      v1001390.ape2_tercero%type;
    l_nom_tercero       v1001390.nom_tercero%type;
    l_nom2_tercero      v1001390.nom2_tercero%type;
    --
  BEGIN
    --
    IF p_tipo IN ('TOMADOR','ASEGURADO') THEN
      -- terceros relacionados con la poliza (tomadores, asegurados, etc.)
      SELECT cod_act_tercero
        INTO p_cod_act_tercero
        FROM a1001331
       WHERE cod_cia    = p_cod_cia
         AND tip_docum  = p_tip_docum
         AND cod_docum  = p_cod_docum
         AND ROWNUM     = 1;
      --
    END IF;
    --
    -- terceros
    SELECT ape1_tercero,
           ape2_tercero,
           nom_tercero,
           nom2_tercero
      INTO l_ape1_tercero, l_ape2_tercero, l_nom_tercero, l_nom2_tercero
      FROM v1001390
     WHERE cod_cia         = p_cod_cia
       AND cod_act_tercero = p_cod_act_tercero
       AND tip_docum       = p_tip_docum
       AND cod_docum       = p_cod_docum;
    --
    IF l_ape1_tercero IS NOT NULL THEN
      l_txt_tercero := l_ape1_tercero;
    END IF;
    --
    IF l_ape2_tercero IS NOT NULL THEN
      --
      IF l_txt_tercero IS NOT NULL THEN
         l_txt_tercero := l_txt_tercero ||', '||l_ape2_tercero;
      ELSE
         l_txt_tercero := l_ape2_tercero;
      END IF;
      --
    END IF;
    --
    IF l_nom_tercero IS NOT NULL THEN
      --
      IF l_txt_tercero IS NOT NULL THEN
         l_txt_tercero := l_txt_tercero ||', '||l_nom_tercero;
      ELSE
         l_txt_tercero := l_nom_tercero;
      END IF;
      --
    END IF;
    --
    RETURN l_txt_tercero;
    --
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    --
  END f_nom_tercero;
  --
  -- devuelve la lista de coberturas asociadas al siniestro/liquidacion
  -- en formato HTML para el email
  FUNCTION f_list_coberturas RETURN VARCHAR2 IS
    --
    l_lista     VARCHAR2(512);
    l_etiqueta  VARCHAR2(30);
    --
    CURSOR c_coberturas IS
      SELECT distinct a.cod_cob, b.nom_cob
        FROM h7001200 a,
             a1002150 b
       WHERE a.cod_cia  = b.cod_cia
         AND a.cod_ramo = b.cod_ramo
         AND a.cod_cob  = b.cod_cob
         AND a.cod_cia  = l_cod_cia
         AND a.num_sini = l_num_sini
         AND a.num_exp  = l_num_exp
         AND a.num_liq  = l_num_liq;
    --
  BEGIN
    --
    l_lista := 'X';
    --
    FOR v IN c_coberturas LOOP
      --
      IF l_lista = 'X' THEN
        --
        l_lista := '';
        l_etiqueta := 'Cobertura Afectada:';
        --
      ELSE
        --
        l_etiqueta := '';
        --
      END IF;
      --
      l_lista := l_lista || '<tr><td>'||l_etiqueta||'</td><td><strong>'||v.nom_cob||'</strong></td></tr>' || chr(13);
      --
    END LOOP;
    --
    RETURN l_lista;
    --
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    --
  END f_list_coberturas;
  --
  -- muestra el lugar siniestro, en formato HTML
  FUNCTION f_lugar_siniestro RETURN VARCHAR2 IS
    --
    l_lista     VARCHAR2(1024);
    l_etiqueta  VARCHAR2(30);
    --
    CURSOR c_lugar IS
      SELECT a.cod_pais_stro,
         ( SELECT b.nom_pais
             FROM a1000101 b
            WHERE b.cod_pais = a.cod_pais_stro
         ) AS nom_pais_stro,
         a.cod_estado_stro,
         ( SELECT b.nom_estado
             FROM a1000104 b
            WHERE b.cod_pais   = a.cod_pais_stro
              AND b.cod_estado = a.cod_estado_stro
         ) AS nom_estado_stro,
         a.cod_prov_stro,
         ( SELECT b.nom_prov
             FROM a1000100 b
            WHERE b.cod_pais   = a.cod_pais_stro
              AND b.cod_estado = a.cod_estado_stro
              AND b.cod_prov   = a.cod_prov_stro
         ) AS nom_prov_stro,
         a.nom_localidad_stro
    FROM a7000950 a
   WHERE a.cod_cia  = l_cod_cia
     AND a.num_sini = l_num_sini;
    --
  BEGIN
    --
    l_lista := 'S/D';
    --
    FOR v IN c_lugar LOOP
      --
      IF l_lista = 'S/D' THEN
         l_lista := '';
         l_etiqueta := 'Lugar Siniestro:';
      ELSE
        l_etiqueta := '';
      END IF;
      --
      l_lista := l_lista || '<tr><td>'||l_etiqueta||
         '</td><td><strong>'||v.nom_pais_stro||' ' ||v.nom_estado_stro||' '||v.nom_prov_stro||' '||v.nom_localidad_stro ||
         '</strong></td></tr>' || chr(13);
      --
    END LOOP;
    --
    IF l_lista = 'S/D' THEN
      l_lista :=  '<tr><td>Lugar Siniestro:</td><td>Sin Informacion!</td></tr>';
    END IF;
    --
    RETURN l_lista;
    --
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
    --
  END f_lugar_siniestro;
  --
  -- devuelve el email del beneficiario
  FUNCTION f_email_beneficiario RETURN VARCHAR2 IS
    --
    CURSOR c_datos IS
    SELECT a.num_ord_pago, b.cod_act_tercero, a.tip_docum, a.cod_docum,
           a.cod_tercero, c.nom_act_tercero
      FROM a3001700 a,
           v1001390 b,
           a1002200 c
     WHERE a.cod_cia = l_cod_cia
       AND a.mca_provisional = 'N'
       AND a.num_sini = l_num_sini
       AND a.num_exp  = l_num_exp
       AND a.cod_cia = b.cod_cia
       AND a.tip_docum = b.tip_docum
       AND a.cod_docum = b.cod_docum
       AND a.cod_act_tercero = b.cod_act_tercero
       AND b.cod_act_tercero = c.cod_act_tercero;
    --
  BEGIN
    --
    FOR v IN c_datos LOOP
      --
      dc_k_terceros.p_lee( p_cod_cia     => l_cod_cia,
                           p_tip_docum   => v.tip_docum,
                           p_cod_docum   => v.cod_docum,
                           p_cod_tercero => v.cod_tercero,
                           p_fec_validez => trunc(sysdate),
                           p_cod_act_tercero => v.cod_act_tercero
                         );
      --
      RETURN dc_k_terceros.f_email_com;
      --
    END LOOP;
    --
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;  -- SE DEBE RETORNAR UN EMAIL DE FALLOS
    --
  END f_email_beneficiario;
  --
  -- devuelve el email del tramitador
  FUNCTION f_email_tramitador RETURN VARCHAR2 IS
    --
    CURSOR c_tramitadores IS
      SELECT tip_docum, cod_docum, cod_act_tercero
        FROM a1001339
       WHERE cod_cia        = l_cod_cia
         AND cod_tramitador = l_cod_tramitador;
    --
  BEGIN
    --
    FOR v IN c_tramitadores LOOP
      dc_k_terceros.p_lee( p_cod_cia   => l_cod_cia,
                           p_tip_docum => v.tip_docum,
                           p_cod_docum => v.cod_docum,
                           p_cod_tercero => l_cod_tramitador,
                           p_fec_validez => trunc(sysdate),
                           p_cod_act_tercero => v.cod_act_tercero
                         );
       RETURN dc_k_terceros.f_email_com;
    END LOOP;
    --
    EXCEPTION
      WHEN OTHERS THEN
        RETURN NULL;
  END f_email_tramitador;
  --
BEGIN
  --
  -- lee los datos iniciales
  p_lee_liquidacion;
  p_lee_expediente;
  p_lee_siniestro;
  p_lee_poliza;
  --
  -- obtenemos el nombre del productor de la polzia
  l_productor := f_nom_tercero( p_cod_cia         => l_cod_cia,
                                p_tip_docum       => l_tip_docum_agt,
                                p_cod_docum       => l_cod_docum_agt,
                                p_cod_act_tercero => l_cod_act_agt,
                                p_tipo            => 'AGENTE'
                              );
  --
  -- obtenemos el nombre de tercero (TOMADOR) de la poliza
  l_tomador := f_nom_tercero( p_cod_cia         => l_cod_cia,
                              p_tip_docum       => l_tip_docum_tom,
                              p_cod_docum       => l_cod_docum_tom,
                              p_cod_act_tercero => l_cod_act_tom,
                              p_tipo            => 'TOMADOR'
                            );
  --
  -- obtenemos el nombre del asegurado
  l_asegurado := f_nom_tercero( p_cod_cia       => l_cod_cia,
                              p_tip_docum       => l_tip_docum_ase,
                              p_cod_docum       => l_cod_docum_ase,
                              p_cod_act_tercero => l_cod_act_ase,
                              p_tipo            => 'ASEGURADO'
                            );
  --
  -- obtenemos el email del beneficiario
  l_email_beneficiario := f_email_beneficiario;
  l_email_tramitador   := f_email_tramitador;
  --
  -- se arma el HTML cuerpo del MSG
  l_msg := l_msg ||'<p>Le informamos que hemos procedido a liquidar expendiente de Siniestro que afecta la p'||chr(243)||'liza ' ||
                   'cuyos datos se indican a continuaci'||chr(243)||'n:</p>'|| chr(13);
  --
  -- ! RGUERRA ver 1.01, se corrige texto,  con el '||chr(225)||'rea de reclamos de automoviles de MAPFRE
  -- !                   por con el '||chr(225)||'rea de reclamos de MAPFRE
  l_msg := l_msg ||'<p>Para cualquier aclaraci'||chr(243)||'n, informaci'||chr(243)||'n y debido seguimiento, favor contactarse '||
                   'con el '||chr(225)||'rea de reclamos de MAPFRE<p>'|| chr(13);
  --
  l_msg := l_msg ||'<table>'|| chr(13) ||
                   '<tr><td>Tomador:</td><td><strong>'||l_tomador||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>Asegurado:</td><td><strong>'|| l_asegurado ||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>Siniestro No.:</td><td><strong>'|| l_num_sini ||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>Ramo:</td><td><strong>'|| dc_k_a1001800.f_nom_ramo ||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>P'||chr(243)||'liza No.:</td><td><strong>'|| l_num_poliza ||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>Moneda:</td><td><strong>'|| dc_k_a1000400.f_nom_mon ||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>Fecha Ocurrencia:</td><td><strong>'|| l_fec_sini ||'</strong></td></tr>' || chr(13) ||
                   '<tr><td>Fecha Notificaci'||chr(243)||'n:</td><td><strong>'|| l_fec_denu_sini ||'</strong></td></tr>' || chr(13) ||
                   f_lugar_siniestro ||
                   f_list_coberturas ||
                   '<tr><td>Productor:</td><td><strong>'|| l_productor ||'</strong></td></tr>' || chr(13) ||
                   '</table>';
  --
  -- ! 243 -> ��
  -- El texto debe ser: Notificaci��n de liquidaci��n
  p_send_mail_mrd( 'mapfrebhd@mapfrebhd.com.do',
                   l_email_beneficiario||';'||l_email_tramitador,
                   'Notificaci'||chr(243)||'n de liquidaci'||chr(243)||'n',
                   NULL,
                   l_msg
                 );
  --
  EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line(sqlerrm);
  --
END ts_p_email_final_liq_mrd;
/
