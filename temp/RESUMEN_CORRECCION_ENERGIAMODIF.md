# RESUMEN CORRECCIÓN ENERGIAMODIF

**Fecha:** 2025-12-04
**Componente:** EnergiaModif (Cambios de Energía Eléctrica)
**Estado:** ✅ CORREGIDO

---

## 🔴 PROBLEMA IDENTIFICADO

### Error Reportado
```
SQLSTATE[42883]: Undefined function: 7 ERROR:
function public.sp_energia_modif_buscar(unknown, unknown, unknown, unknown, unknown) does not exist
HINT:  No function matches the given name and argument types. You might need to add explicit type casts.
```

### Causa Raíz
Los stored procedures `sp_energia_modif_buscar` y `sp_energia_modif_modificar` contenían **referencias cross-database incorrectas** en PostgreSQL.

**Sintaxis incorrecta usada:**
```sql
FROM padron_licencias.comun.ta_11_locales l
INNER JOIN padron_licencias.db_ingresos.ta_11_energia e
```

**Sintaxis correcta en PostgreSQL:**
```sql
FROM comun.ta_11_locales l
INNER JOIN db_ingresos.ta_11_energia e
```

### Explicación
En PostgreSQL:
- ✅ Correcto: `schema.tabla` (ej: `comun.ta_11_locales`)
- ❌ Incorrecto: `database.schema.tabla` (ej: `padron_licencias.comun.ta_11_locales`)

PostgreSQL no soporta la notación de 3 niveles (database.schema.tabla) como Informix.

---

## ✅ SOLUCIÓN APLICADA

### Archivos Corregidos

#### 1. **EnergiaModif_sp_energia_modif_buscar.sql**
- **Ubicación:** `RefactorX\Base\mercados\database\database\`
- **Cambios:** Eliminadas referencias `padron_licencias.` en líneas 47-48
- **Tablas afectadas:**
  - `comun.ta_11_locales`
  - `db_ingresos.ta_11_energia`

#### 2. **EnergiaModif_sp_energia_modif_modificar.sql**
- **Ubicación:** `RefactorX\Base\mercados\database\database\`
- **Cambios:** Eliminadas referencias `padron_licencias.` en 7 ubicaciones
- **Tablas afectadas:**
  - `db_ingresos.ta_11_energia`
  - `db_ingresos.ta_11_energia_hist`
  - `db_ingresos.ta_11_adeudo_energ`

---

## 📦 ARCHIVOS DE DESPLIEGUE

### Archivo SQL Consolidado
**Ubicación:** `temp\deploy_energiamodif_sps_corregidos.sql`

Contiene ambos SPs corregidos:
1. `sp_energia_modif_buscar`
2. `sp_energia_modif_modificar`

### Script de Despliegue Automático
**Ubicación:** `temp\DEPLOY_ENERGIAMODIF_FIX.bat`

Para ejecutar:
```bash
cd temp
DEPLOY_ENERGIAMODIF_FIX.bat
```

El script:
1. Muestra información sobre lo que se desplegará
2. Ejecuta el archivo SQL en la base `padron_licencias`
3. Confirma el despliegue exitoso

---

## 🎯 STORED PROCEDURES CORREGIDOS

### 1. sp_energia_modif_buscar
**Parámetros:**
- `p_oficina` INTEGER
- `p_num_mercado` INTEGER
- `p_categoria` INTEGER
- `p_seccion` VARCHAR
- `p_local` INTEGER
- `p_letra_local` VARCHAR
- `p_bloque` VARCHAR

**Función:** Busca el registro de energía para un local específico.

**Retorna:** Datos del registro de energía incluyendo:
- id_energia, id_local, cve_consumo
- local_adicional, cantidad, vigencia
- fecha_alta, fecha_baja, fecha_modificacion
- id_usuario

### 2. sp_energia_modif_modificar
**Parámetros:**
- `p_id_energia` INTEGER
- `p_id_local` INTEGER
- `p_cantidad` NUMERIC
- `p_vigencia` VARCHAR
- `p_fecha_alta` DATE
- `p_fecha_baja` DATE
- `p_movimiento` VARCHAR (A/B/C/D/F)
- `p_cve_consumo` VARCHAR
- `p_local_adicional` VARCHAR
- `p_usuario_id` INTEGER
- `p_periodo_baja_axo` INTEGER
- `p_periodo_baja_mes` INTEGER

**Función:** Modifica el registro de energía y actualiza historial y adeudos según reglas de negocio.

**Tipos de Movimiento:**
- **A** = Alta/Cambio
- **B** = Baja (requiere periodo de baja)
- **C** = Cambio Simple
- **D** = Actualizar desde Periodo (requiere periodo)
- **F** = Recalcular Completo (elimina y regenera todos los adeudos)

**Retorna:** `{ success: boolean, message: text }`

---

## 🔄 INTEGRACIÓN CON VUE

El componente Vue `EnergiaModif.vue` llama estos SPs así:

### Búsqueda de Local
```javascript
const response = await axios.post('/api/generic', {
  eRequest: {
    Operacion: 'sp_energia_modif_buscar',
    Base: 'padron_licencias',
    Parametros: [
      { Nombre: 'p_oficina', Valor: parseInt(oficina) },
      { Nombre: 'p_num_mercado', Valor: parseInt(num_mercado) },
      { Nombre: 'p_categoria', Valor: parseInt(categoria) },
      { Nombre: 'p_seccion', Valor: seccion },
      { Nombre: 'p_local', Valor: parseInt(local) },
      { Nombre: 'p_letra_local', Valor: letra_local || null },
      { Nombre: 'p_bloque', Valor: bloque || null }
    ]
  }
})
```

### Modificación de Energía
```javascript
const response = await axios.post('/api/generic', {
  eRequest: {
    Operacion: 'sp_energia_modif_modificar',
    Base: 'padron_licencias',
    Parametros: [
      { Nombre: 'p_id_energia', Valor: parseInt(id_energia) },
      { Nombre: 'p_id_local', Valor: parseInt(id_local) },
      { Nombre: 'p_cantidad', Valor: parseFloat(cantidad) },
      { Nombre: 'p_vigencia', Valor: vigencia },
      { Nombre: 'p_fecha_alta', Valor: fecha_alta },
      { Nombre: 'p_fecha_baja', Valor: fecha_baja || null },
      { Nombre: 'p_movimiento', Valor: movimiento },
      { Nombre: 'p_cve_consumo', Valor: cve_consumo },
      { Nombre: 'p_local_adicional', Valor: local_adicional || null },
      { Nombre: 'p_usuario_id', Valor: 1 },
      { Nombre: 'p_periodo_baja_axo', Valor: axo || null },
      { Nombre: 'p_periodo_baja_mes', Valor: mes || null }
    ]
  }
})
```

---

## 📋 PASOS SIGUIENTES

### 1. Iniciar PostgreSQL
```bash
# Verificar que PostgreSQL esté corriendo
# Si no, iniciarlo desde pgAdmin o servicios de Windows
```

### 2. Ejecutar el Despliegue
```bash
cd C:\guadalajara\code\recodeGDLCurrent\recodeGDL\temp
DEPLOY_ENERGIAMODIF_FIX.bat
```

### 3. Verificar en la Aplicación
1. Iniciar el backend Laravel
2. Iniciar el frontend Vue
3. Navegar a: **Mercados > Energía Eléctrica > Cambios de Energía Eléctrica**
4. Probar la búsqueda de un local
5. Probar la modificación de un registro

### 4. Casos de Prueba Sugeridos

**Búsqueda:**
- Buscar un local existente con energía
- Buscar un local sin registro de energía
- Probar con diferentes recaudadoras

**Modificación:**
- Movimiento A (Alta/Cambio)
- Movimiento B (Baja) - debe pedir periodo
- Movimiento F (Recalcular) - debe regenerar adeudos

---

## ⚠️ VALIDACIONES IMPLEMENTADAS

El SP `sp_energia_modif_modificar` incluye:

1. ✅ Validación de cantidad (no null, no 0)
2. ✅ Validación de coherencia movimiento-vigencia
3. ✅ Validación de periodo de baja requerido
4. ✅ Inserción en historial antes de modificar
5. ✅ Actualización de tabla principal
6. ✅ Gestión de adeudos según tipo de movimiento

---

## 🎉 RESULTADO ESPERADO

Después del despliegue:
- ✅ El componente EnergiaModif funcionará correctamente
- ✅ Las búsquedas de locales devolverán resultados
- ✅ Las modificaciones se aplicarán correctamente
- ✅ El historial se mantendrá
- ✅ Los adeudos se actualizarán según reglas de negocio

---

## 📞 NOTAS

Si el error persiste después del despliegue, verificar:
1. Que PostgreSQL esté corriendo
2. Que el despliegue se ejecutó sin errores
3. Que los schemas `comun` y `db_ingresos` existen
4. Que las tablas mencionadas existen en sus respectivos schemas
5. Que el GenericController esté usando el schema `public` para buscar los SPs

---

**Preparado por:** Claude Code
**Fecha:** 2025-12-04
