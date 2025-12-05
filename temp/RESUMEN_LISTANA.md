# 🎯 SOLUCIÓN RÁPIDA: ListAna.vue

## ❌ PROBLEMA
El formulario ListAna.vue muestra el error:
```
El Stored Procedure 'recaudadora_listana' no existe
```

## ✅ SOLUCIÓN EN 3 PASOS

### 1️⃣ Despliega el Stored Procedure
Ejecuta este archivo en tu base de datos PostgreSQL:
```
C:\recodeGDL\temp\DEPLOY_LISTANA_MANUAL.sql
```

**Comando:**
```bash
psql -h localhost -U postgres -d prueba2 -f "C:/recodeGDL/temp/DEPLOY_LISTANA_MANUAL.sql"
```

O usa pgAdmin/DBeaver y copia el contenido del archivo.

---

### 2️⃣ Verifica el despliegue
Ejecuta esta query para verificar:
```sql
SELECT
    n.nspname as "Schema",
    p.proname as "Nombre"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'recaudadora_listana'
AND n.nspname = 'db_ingresos';
```

**Resultado esperado:**
```
Schema       | Nombre
-------------|--------------------
db_ingresos  | recaudadora_listana
```

---

### 3️⃣ Prueba el formulario
Abre el formulario en tu navegador:
```
http://localhost:5173/multas_reglamentos/ListAna
```

---

## 🧪 TRES EJEMPLOS PARA PROBAR

### EJEMPLO 1: Sin filtro
```
Campo "Filtro": [Dejar vacío]
Click en "Buscar"
```
**Resultado:** Las 10 multas más recientes

---

### EJEMPLO 2: Buscar por año
```
Campo "Filtro": 2024
Click en "Buscar"
```
**Resultado:** Solo multas del año 2024

---

### EJEMPLO 3: Buscar por nombre
```
Campo "Filtro": MARIA
Click en "Buscar"
```
**Resultado:** Multas de contribuyentes con "MARIA" en el nombre

---

## 📊 DATOS QUE VERÁS

Cada registro muestra:
- ✅ **Folio:** MULTA-2024-001234
- ✅ **Fecha:** 2024-03-15
- ✅ **Contribuyente:** Nombre completo
- ✅ **Domicilio:** Dirección
- ✅ **Dependencia:** Protección Civil, Reglamentos, etc.
- ✅ **Zona/Subzona:** Z2 / SZ5
- ✅ **Calificación:** $1,000.00
- ✅ **Multa:** $1,000.00
- ✅ **Gastos:** $250.00
- ✅ **Total:** $1,250.00
- ✅ **Tipo:** Normal / Reincidente / Especial
- ✅ **Estado:** Pendiente / Pagada / Cancelada

---

## 🔍 BÚSQUEDAS SOPORTADAS

El filtro busca en:
- ✅ Nombre del contribuyente
- ✅ Dirección (domicilio)
- ✅ Giro del negocio
- ✅ Número de acta
- ✅ Año del acta

**Ejemplos:**
```
"MARIA"      → Busca en nombres
"MEXICO"     → Busca en direcciones
"2024"       → Busca por año
"12345"      → Busca por número de acta
"RESTAURANT" → Busca en giros
```

La búsqueda NO distingue mayúsculas/minúsculas.

---

## 🎮 FUNCIONALIDADES

### Paginación
- ✅ Botones anterior/siguiente
- ✅ Indicador de página actual
- ✅ Total de registros disponibles

### Tamaño de página
Puedes elegir mostrar:
- 10 registros por página
- 25 registros por página
- 50 registros por página

### Ordenamiento
Los resultados se ordenan por:
1. Año (más reciente primero)
2. Número de acta (más reciente primero)

---

## 📝 ARCHIVOS CREADOS

| Archivo | Descripción |
|---------|-------------|
| `DEPLOY_LISTANA_MANUAL.sql` | Script SQL para desplegar el SP |
| `INSTRUCCIONES_LISTANA.md` | Documentación completa (este archivo) |
| `test_api_listana.php` | Script de pruebas de la API |

---

## ⚡ DATOS TÉCNICOS

- **Stored Procedure:** `db_ingresos.recaudadora_listana`
- **Tabla origen:** `comun.multas` (415,017 registros)
- **Parámetros:**
  - `p_filtro` (VARCHAR): Término de búsqueda
  - `p_offset` (INTEGER): Registro inicial (default: 0)
  - `p_limit` (INTEGER): Registros por página (default: 10)

---

## ✅ CHECKLIST

Antes de usar el formulario, verifica:

- [ ] Servidor PostgreSQL está corriendo
- [ ] SP desplegado en db_ingresos
- [ ] Verificación con SELECT muestra el SP
- [ ] Formulario Vue abre sin errores
- [ ] Click en "Buscar" muestra resultados

---

## 🆘 SOLUCIÓN DE PROBLEMAS

### Error: "Connection refused"
**Solución:** Inicia el servidor PostgreSQL

### Error: "SP no existe"
**Solución:** Ejecuta DEPLOY_LISTANA_MANUAL.sql

### Error: "Sin resultados"
**Solución:** Verifica que la tabla comun.multas tenga datos

---

## 📞 SOPORTE

Si tienes problemas:
1. Revisa `INSTRUCCIONES_LISTANA.md` (documentación completa)
2. Ejecuta `test_api_listana.php` para diagnosticar
3. Verifica los logs de PostgreSQL

---

**Fecha:** 2025-12-03
**Estado:** ✅ Listo para usar
**Estimado:** 5 minutos para desplegar y probar
