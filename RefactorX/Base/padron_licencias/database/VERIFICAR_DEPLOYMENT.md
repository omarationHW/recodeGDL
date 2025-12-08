# 📋 GUÍA DE VERIFICACIÓN DE DEPLOYMENT

## ⚠️ Estado Actual
El servidor de base de datos (192.168.6.146) no está accesible desde esta máquina.

## 🔧 Opciones para Verificar

### Opción 1: Ejecutar desde el Servidor
Copia el archivo `verificar_sps.php` al servidor y ejecútalo:
```bash
php verificar_sps.php
```

### Opción 2: Usar psql Directamente
Conectar al servidor y ejecutar:
```bash
psql -h 192.168.6.146 -U refact -d padron_licencias -f VERIFICAR_TODOS_SPS.sql
```

### Opción 3: Verificación Manual con SQL
Ejecuta estas consultas en pgAdmin o cualquier cliente PostgreSQL:

```sql
-- 1. Contar total de funciones por schema
SELECT n.nspname as schema, COUNT(*) as total
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname IN ('public', 'comun')
  AND p.prokind = 'f'
GROUP BY n.nspname;

-- 2. Listar funciones del schema comun
SELECT p.proname as nombre_sp
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'comun'
  AND p.prokind = 'f'
ORDER BY p.proname;

-- 3. Verificar extensión pgcrypto
SELECT * FROM pg_extension WHERE extname = 'pgcrypto';

-- 4. Verificar tablas auxiliares
SELECT tablename FROM pg_tables WHERE schemaname = 'comun' ORDER BY tablename;
```

---

## 📁 Archivos SQL a Desplegar

Si los SPs no están desplegados, ejecutar en orden:

### Batch 1-8 (Anteriores)
Los archivos están en `database/ok/` con prefijo numérico.

### Batch 9-16 (Esta Sesión)
```
database/AGENDAVISITASFRM_all_procedures_IMPLEMENTED.sql
database/BUSCAGIROFRM_all_procedures_IMPLEMENTED.sql
database/BUSQUE_all_procedures_IMPLEMENTED.sql
database/CARGADATOSFRM_all_procedures_IMPLEMENTED.sql
database/CARGA_all_procedures_IMPLEMENTED.sql
database/CARGA_IMAGEN_all_procedures_IMPLEMENTED.sql
database/CATASTRODM_all_procedures_IMPLEMENTED.sql
database/CRUCES_all_procedures_IMPLEMENTED.sql
database/EMPRESASFRM_all_procedures_IMPLEMENTED.sql
database/FORMABUSCALLE_all_procedures_IMPLEMENTED.sql
database/CATREQUISITOS_all_procedures_IMPLEMENTED.sql
database/FIRMAUSUARIO_all_procedures_IMPLEMENTED.sql
database/FORMABUSCOLONIA_all_procedures_IMPLEMENTED.sql
database/GRS_DLG_all_procedures_IMPLEMENTED.sql
database/GRUPOSANUNCIOSABCFRM_all_procedures_IMPLEMENTED.sql
database/FIRMA_all_procedures_IMPLEMENTED.sql
database/FRMSELCALLE_all_procedures_IMPLEMENTED.sql
database/LIGAANUNCIOFRM_all_procedures_IMPLEMENTED.sql
database/PSPLASH_all_procedures_IMPLEMENTED.sql
database/OBSERVACIONFRM_all_procedures_IMPLEMENTED.sql
database/SEMAFORO_all_procedures_IMPLEMENTED.sql
database/SGCV2_all_procedures_IMPLEMENTED.sql
database/TDMCONECTION_all_procedures_IMPLEMENTED.sql
database/GIROSVIGENTESCTEXGIROFRM_all_procedures_IMPLEMENTED.sql
database/MODLICADEUDOFRM_all_procedures_IMPLEMENTED.sql
database/REGHFRM_all_procedures_IMPLEMENTED.sql
database/REPESTADISTICOSLICFRM_all_procedures_IMPLEMENTED.sql
database/REPSUSPENDIDASFRM_all_procedures_IMPLEMENTED.sql
database/SFRM_CHGFIRMA_all_procedures_IMPLEMENTED.sql
database/SFRM_CHGPASS_all_procedures_IMPLEMENTED.sql
database/TIPOBLOQUEOFRM_all_procedures_IMPLEMENTED.sql
database/WEBBROWSER_all_procedures_IMPLEMENTED.sql
database/FECHASEGFRM_all_procedures_IMPLEMENTED.sql
```

---

## ✅ Lista de Verificación

- [ ] Conexión a BD exitosa
- [ ] Schema `comun` existe
- [ ] Extensión `pgcrypto` instalada
- [ ] SPs de Batch 1-8 desplegados
- [ ] SPs de Batch 9-16 desplegados
- [ ] Tablas auxiliares creadas
- [ ] Test de SP básico funciona

### Test Rápido de Funcionamiento
```sql
-- Test sp_tipo_bloqueo_list
SELECT * FROM comun.sp_tipo_bloqueo_list(TRUE);

-- Test sp_webbrowser_get_bookmarks
SELECT * FROM comun.sp_webbrowser_get_bookmarks(1, NULL);

-- Test sp_fechasegfrm_list
SELECT * FROM comun.sp_fechasegfrm_list(NULL, NULL, 10);
```

---

## 📞 Troubleshooting

### Error: Connection refused
- Verificar que PostgreSQL esté corriendo
- Verificar puerto 5432 abierto en firewall
- Verificar `pg_hba.conf` permite conexiones remotas

### Error: Schema no existe
```sql
CREATE SCHEMA IF NOT EXISTS comun;
```

### Error: Extension pgcrypto
```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

---

**Generado:** 2025-11-21
**Módulo:** padron_licencias
