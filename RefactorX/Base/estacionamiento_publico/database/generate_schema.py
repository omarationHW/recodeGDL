import json

schema_data = {
  "fecha_analisis": "2025-11-09",
  "modulo": "estacionamiento_publico",
  "ubicacion_fuentes": "database/database",
  "total_archivos_sql": 182,
  "esquemas": ["public", "comun"],
  "tablas_identificadas": [
    "ta14_folios_adeudo", "ta14_folios_histo", "ta14_personas", "ta14_tarifas",
    "ta14_datos_mpio", "ta14_datos_edo", "ta14_bitacora", "ta14_calco",
    "ta14_calcomanias", "ta14_agentes", "ta14_adicional_mmeters", "ta14_folios_free",
    "ta14_fol_banorte", "ta14_notifica_edo", "ta14_condonado", "ta14_refrecibo",
    "ta14_codigomovtos", "ta14_infraccion", "ta14_folios_baja_esta",
    "usuarios", "ta_12_passwords", "ta_contrarecibos", "ta_proveedores",
    "predio_virtual", "ta_ubicaciones", "ta_padron", "ta_sp",
    "ta_14_cve_importe", "ta_14_folios", "ta_15_publicos", "ta_18_exclusivo"
  ],
  "tablas_principales": {
    "ta14_folios_adeudo": {
      "descripcion": "Folios de adeudo (multas) vigentes",
      "columnas_clave": ["axo", "folio", "placa", "fecha_folio", "infraccion", "estado", "vigilante"],
      "relaciones": ["ta14_tarifas", "ta14_personas", "ta14_folios_free"]
    },
    "ta14_folios_histo": {
      "descripcion": "Histórico de folios pagados/cancelados",
      "columnas_clave": ["control", "axo", "folio", "placa", "fecha_movto"],
      "relaciones": ["ta14_fol_banorte", "ta14_condonado"]
    },
    "ta14_datos_mpio": {
      "descripcion": "Datos municipales de remesas",
      "columnas_clave": ["tipoact", "folio", "axo", "placa", "remesa", "fechapago"],
      "relaciones": ["ta14_bitacora"]
    },
    "ta14_datos_edo": {
      "descripcion": "Datos del estado (remesas recibidas)",
      "columnas_clave": ["tipoact", "folio", "placa", "remesa", "fecpago"],
      "relaciones": ["ta14_bitacora"]
    }
  },
  "tablas_catalogo": {
    "ta14_personas": "Catálogo de personas (propietarios, inspectores)",
    "ta14_tarifas": "Catálogo de tarifas de infracciones",
    "ta14_infraccion": "Catálogo de infracciones",
    "ta14_agentes": "Catálogo de agentes/inspectores",
    "ta_proveedores": "Catálogo de proveedores",
    "usuarios": "Usuarios del sistema",
    "ta_12_passwords": "Usuarios legacy"
  },
  "stored_procedures": {
    "total": 182,
    "grupos": ["Acceso", "ConsGral", "ConsRemesas", "AplicaPgo_DivAdmin", "Bja_Multiple", "Cga_ArcEdoEx", "DM_Crbos", "frmMetrometers", "Gen_ArcAltas", "Gen_PgosBanorte", "Reactiva_Folios", "sfrm_transfolios", "sdmWebService"]
  },
  "resumen": {
    "total_tablas": 30,
    "total_sps": 182,
    "esquemas": 2,
    "tablas_principales": 4,
    "tablas_catalogo": 7,
    "tablas_auxiliares": 19
  }
}

with open('db-schema-validation.json', 'w', encoding='utf-8') as f:
    json.dump(schema_data, f, indent=2, ensure_ascii=False)
print("OK")
