-- Stored Procedure: sp_doctosfrm_catalog
-- Tipo: Catalog
-- Descripción: Devuelve el catálogo de documentos posibles para el formulario doctosfrm.
-- Generado para formulario: doctosfrm
-- Fecha: 2025-08-27 17:40:17

CREATE OR REPLACE FUNCTION sp_doctosfrm_catalog()
RETURNS TABLE(codigo text, descripcion text) AS $$
BEGIN
  RETURN QUERY VALUES
    ('fotofachada', 'Fotografías de la fachada'),
    ('recibopredial', 'Recibo de predial'),
    ('ident_titular', 'Identificación titular'),
    ('ident_dueno_finca', 'Identificación del dueño de la finca'),
    ('ident_r1', 'Identificación R1 (alta de Hacienda)'),
    ('contrato_arrend', 'Contrato de arrendamiento'),
    ('solic_lic_usosuelo', 'Solicitud de licencia y uso de suelo'),
    ('solic_mod_padron', 'Solicitud de modificación al padrón y uso de suelo'),
    ('licencia_vigente', 'Licencia original vigente'),
    ('carta_policia', 'Carta de policía'),
    ('carta_poder', 'Carta de poder simple'),
    ('memoria_calculo', 'Memoria de cálculo'),
    ('poliza_responsabilidad', 'Póliza vigente de responsabilidad civil del anuncio'),
    ('acta_constitutiva', 'Acta constitutiva'),
    ('poder_notarial', 'Poder notarial'),
    ('asignacion_numeros', 'Asignación de números'),
    ('copia_licencia', 'Copia de licencia'),
    ('solic_lic_anuncio', 'Solicitud de licencia y anuncio'),
    ('solic_dictamen_anuncio', 'Solicitud de dictamen de anuncio');
END;
$$ LANGUAGE plpgsql;