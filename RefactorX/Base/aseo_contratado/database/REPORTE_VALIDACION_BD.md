## 📋 REPORTE AGENTE 1 - VALIDACIÓN SPs EN BD

**Fecha:** 2025-11-10 01:20:57
**SPs en BD:** 39
**Archivos SQL:** 483
**Estado:** ✅ SPs ENCONTRADOS

### Resumen
- Total SPs encontrados en BD: 39
- Total archivos SQL en /database: 364
- Total archivos SQL en /ok: 119
- SPs con formato eResponse: 0
- Esquemas encontrados: catastro_gdl, cnx_com, cnx_merca, comun, comunX, db_egresos, db_gasto2002, db_ingresos, dbestacion, dbingresosvw, informix, informix_migration, public, publicX

### Primeros 20 SPs Encontrados

| # | Esquema | Función | eResponse | Parámetros |
|---|---------|---------|-----------|------------|
| 1 | catastro_gdl | sp_bajalicencia_adeudos | ❌ | p_licencia integer |
| 2 | catastro_gdl | sp_consultalicencia_get_adeudos | ❌ | p_licencia integer, p_tipo character varying DEFAU... |
| 3 | catastro_gdl | sp_empresas_list | ❌ | p_rfc text DEFAULT NULL::text, p_razon_social text... |
| 4 | catastro_gdl | sp_empresas_list | ❌ | Sin parámetros |
| 5 | catastro_gdl | sp_empresas_search | ❌ | p_busqueda character varying DEFAULT NULL::charact... |
| 6 | catastro_gdl | sp_giros_adeudo_report | ❌ | p_anio integer |
| 7 | catastro_gdl | sp_licencia_adeudos | ❌ | p_id_licencia integer |
| 8 | catastro_gdl | sp_zonas_list | ❌ | Sin parámetros |
| 9 | catastro_gdl | sp_zonas_modificar_list | ❌ | Sin parámetros |
| 10 | comun | sp_empresas_create | ❌ | p_propietario character, p_ubicacion character, p_... |
| 11 | comun | sp_empresas_delete | ❌ | p_empresa integer, p_usuario character DEFAULT NUL... |
| 12 | comun | sp_empresas_estadisticas | ❌ | Sin parámetros |
| 13 | comun | sp_empresas_get | ❌ | p_empresa integer |
| 14 | comun | sp_empresas_list | ❌ | p_page integer DEFAULT 1, p_page_size integer DEFA... |
| 15 | comun | sp_empresas_update | ❌ | p_empresa integer, p_propietario character, p_rfc ... |
| 16 | comun | sp_modlic_recalcular_adeudo_anuncio | ❌ | p_id_anuncio integer, p_id_licencia integer |
| 17 | comun | tramitebajalic_spget_lic_adeudos | ❌ | v_id integer, v_tipo character varying |
| 18 | public | sp_empresas_create | ❌ | Sin parámetros |
| 19 | public | sp_empresas_delete | ❌ | Sin parámetros |
| 20 | public | sp_empresas_estadisticas | ❌ | Sin parámetros |

_... y 19 SPs más_
