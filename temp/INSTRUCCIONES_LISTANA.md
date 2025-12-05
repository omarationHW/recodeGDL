# SOLUCIÓN: ListAna.vue - Stored Procedure recaudadora_listana

## 📋 PROBLEMA IDENTIFICADO

El formulario ListAna.vue está intentando llamar al stored procedure `recaudadora_listana` pero no existe en la base de datos.

**Error:**
```
El Stored Procedure 'recaudadora_listana' no existe en el esquema 'public'
```

## ✅ SOLUCIÓN

### Paso 1: Desplegar el Stored Procedure

Ejecuta el siguiente archivo SQL en tu base de datos PostgreSQL:

**Archivo:** `C:\recodeGDL\temp\DEPLOY_LISTANA_MANUAL.sql`

**Comando para desplegar:**
```bash
psql -h localhost -U postgres -d prueba2 -f "C:/recodeGDL/temp/DEPLOY_LISTANA_MANUAL.sql"
```

O copia y pega el contenido del archivo en tu cliente PostgreSQL (pgAdmin, DBeaver, etc.)

---

## 🧪 TRES EJEMPLOS PARA PROBAR EL FORMULARIO

### EJEMPLO 1: Buscar sin filtro
**Descripción:** Ver las últimas multas registradas (sin ningún filtro)

**En el formulario HTML:**
- Campo "Filtro": Dejar vacío
- Click en botón "Buscar"

**Query equivalente:**
```sql
SELECT * FROM db_ingresos.recaudadora_listana('', 0, 10);
```

**Resultado esperado:**
- Lista de las 10 multas más recientes
- Ordenadas por año y número de acta descendente
- Incluye total_count para paginación

**Datos que verás:**
```
Folio: MULTA-2024-001234
Contribuyente: JUAN PEREZ LOPEZ
Domicilio: AV MEXICO 123
Dependencia: Reglamentos
Total: $1,500.00
Estado: Pendiente
```

---

### EJEMPLO 2: Buscar por año
**Descripción:** Ver multas de un año específico

**En el formulario HTML:**
- Campo "Filtro": Escribe `2024`
- Click en botón "Buscar"

**Query equivalente:**
```sql
SELECT * FROM db_ingresos.recaudadora_listana('2024', 0, 10);
```

**Resultado esperado:**
- Solo multas del año 2024
- Máximo 10 registros por página
- Campo total_count mostrará cuántas multas hay en total de 2024

**Datos que verás:**
```
Folio: MULTA-2024-005678
Contribuyente: MARIA GONZALEZ RAMIREZ
Domicilio: CALLE INDEPENDENCIA 456
Dependencia: Protección Civil
Total: $2,300.00
Estado: Pagada
```

---

### EJEMPLO 3: Buscar por nombre
**Descripción:** Buscar multas de un contribuyente específico

**En el formulario HTML:**
- Campo "Filtro": Escribe `MARIA`
- Click en botón "Buscar"

**Query equivalente:**
```sql
SELECT * FROM db_ingresos.recaudadora_listana('MARIA', 0, 10);
```

**Resultado esperado:**
- Todas las multas donde el contribuyente contenga "MARIA"
- La búsqueda NO es case-sensitive (mayúsculas/minúsculas)
- También busca en domicilio y giro

**Datos que verás:**
```
Folio: MULTA-2023-009876
Contribuyente: MARIA DEL CARMEN LOPEZ
Domicilio: CALZADA INDEPENDENCIA 789
Dependencia: Mercados
Zona/Subzona: Z2 / SZ5
Calificación: $1,000.00
Multa: $1,000.00
Gastos: $250.00
Total: $1,250.00
Tipo: Normal
Estado: Pendiente
```

---

## 📊 CAMPOS QUE RETORNA EL SP

El stored procedure retorna los siguientes campos para mostrar en la tabla:

| Campo | Descripción | Ejemplo |
|-------|-------------|---------|
| `total_count` | Total de registros (para paginación) | 415017 |
| `id_multa` | ID único de la multa | 12345 |
| `folio` | Folio formateado | MULTA-2024-001234 |
| `fecha_acta` | Fecha del acta | 2024-03-15 |
| `contribuyente` | Nombre del contribuyente | JUAN PEREZ LOPEZ |
| `domicilio` | Dirección | AV MEXICO 123 |
| `dependencia` | Dependencia emisora | Reglamentos |
| `zona_subzona` | Zona y subzona | Z2 / SZ5 |
| `calificacion` | Monto de calificación | 1000.00 |
| `multa` | Monto de la multa | 1000.00 |
| `gastos` | Gastos adicionales | 250.00 |
| `total` | Total a pagar | 1250.00 |
| `tipo` | Tipo de multa | Normal/Reincidente/Especial |
| `estado` | Estado actual | Pendiente/Pagada/Cancelada |

---

## 🔍 FILTROS SOPORTADOS

El parámetro `p_filtro` busca en los siguientes campos:
- ✅ Contribuyente (nombre)
- ✅ Domicilio
- ✅ Giro del negocio
- ✅ Número de acta
- ✅ Año del acta

**Ejemplos de búsquedas:**
```
'MARIA'      → Busca en nombre
'MEXICO'     → Busca en domicilio
'2024'       → Busca por año
'12345'      → Busca por número de acta
'RESTAURANT' → Busca en giro
```

---

## 🎯 FUNCIONALIDADES DEL FORMULARIO

### Paginación
- **Primera página:** offset=0, limit=10
- **Segunda página:** offset=10, limit=10
- **Tercera página:** offset=20, limit=10

### Ordenamiento
Los resultados se ordenan por:
1. Año del acta (descendente)
2. Número de acta (descendente)
3. ID de multa (descendente)

Esto significa que siempre verás las multas más recientes primero.

### Selector de registros por página
El formulario permite cambiar cuántos registros mostrar:
- 10 registros
- 25 registros
- 50 registros

---

## 📝 VERIFICACIÓN POST-DESPLIEGUE

Después de desplegar el SP, verifica que existe con:

```sql
SELECT
    n.nspname as "Schema",
    p.proname as "Nombre",
    pg_get_function_arguments(p.oid) as "Argumentos"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE p.proname = 'recaudadora_listana'
AND n.nspname = 'db_ingresos';
```

**Resultado esperado:**
```
Schema       | Nombre              | Argumentos
-------------|---------------------|------------------------------
db_ingresos  | recaudadora_listana | p_filtro character varying,
             |                     | p_offset integer DEFAULT 0,
             |                     | p_limit integer DEFAULT 10
```

---

## 🚀 PRUEBA EN EL NAVEGADOR

1. Abre el formulario: `http://localhost:5173/multas_reglamentos/ListAna`
2. Deja el campo filtro vacío
3. Click en "Buscar"
4. Deberías ver una tabla con 10 registros
5. Prueba los ejemplos descritos arriba

---

## 📌 DATOS DE LA TABLA REAL

El SP consulta la tabla real: **comun.multas**
- Total de registros: 415,017 multas
- Filtros aplicados:
  - Solo multas con total > 0
  - Solo multas con contribuyente registrado
  - Solo años válidos (0 < año < 2100)

---

## ⚠️ NOTAS IMPORTANTES

1. **Schema correcto:** El SP debe estar en `db_ingresos`, NO en `public`
2. **Tabla origen:** Usa `comun.multas` (tabla real con 415K registros)
3. **Paginación server-side:** El total_count se calcula UNA sola vez para eficiencia
4. **Búsqueda case-insensitive:** Los filtros no distinguen mayúsculas/minúsculas
5. **Performance:** La consulta incluye índices en las columnas de búsqueda

---

## ✅ CHECKLIST DE VALIDACIÓN

- [ ] SP desplegado en db_ingresos
- [ ] Verificación con query SELECT exitosa
- [ ] Prueba sin filtro muestra resultados
- [ ] Prueba con filtro '2024' funciona
- [ ] Prueba con filtro 'MARIA' funciona
- [ ] Paginación funciona (botones anterior/siguiente)
- [ ] Total_count muestra correctamente
- [ ] Formulario Vue se conecta sin errores

---

## 🎉 RESULTADO FINAL

Una vez desplegado el SP, el formulario ListAna.vue funcionará correctamente mostrando:
- ✅ Listado analítico de multas
- ✅ Búsqueda por múltiples criterios
- ✅ Paginación server-side eficiente
- ✅ Información detallada de cada multa
- ✅ Ordenamiento por fecha descendente

---

**Fecha:** 2025-12-03
**Módulo:** multas_reglamentos
**Archivo Vue:** RefactorX/FrontEnd/src/views/modules/multas_reglamentos/ListAna.vue
**SP:** db_ingresos.recaudadora_listana
