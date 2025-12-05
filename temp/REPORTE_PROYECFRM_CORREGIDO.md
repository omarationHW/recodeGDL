# CORRECCIÓN PROYECFRM - PROBLEMA DE DUPLICADOS RESUELTO ✅

## PROBLEMA IDENTIFICADO

El Stored Procedure `recaudadora_proyecfrm` estaba devolviendo **duplicados** porque:
- Un proyecto puede tener múltiples registros en `ta_proyecto_pres` (uno por cada combinación de dependencia/partida/programa)
- El proyecto 4 tenía 6 registros de presupuesto
- El LEFT JOIN multiplicaba las filas

**Resultado**: Los mismos proyectos aparecían múltiples veces

## SOLUCIÓN APLICADA

Se agregó **GROUP BY** para consolidar los datos por proyecto:
- `GROUP BY p.ejercicio, p.proyecto, p.descripcion`
- Se usó `MAX()` para columnas únicas (dependencia, partida, programa, fecha_alta)
- Se usó `SUM()` para totales de presupuesto
- Se agregó `COALESCE()` para manejar valores NULL

## RESULTADOS DESPUÉS DE LA CORRECCIÓN

### EJEMPLO 1: Sin filtro (vacío)
**Primeros 5 proyectos únicos del ejercicio más reciente:**
1. Proyecto 4: POR UN GUADALAJARA SIN BACHES (RECONSTRUCCIÓN)
2. Proyecto 6: MODERNIZACION CATASTRAL 2A ETAPA
3. Proyecto 8: EMPRENDE-GUADALAJARA
4. Proyecto 15: MODERNIZACION DE LA ADMINISTRACIÓN TRIBUTARIA
5. Proyecto 19: VIA RE-ACTIVA

✅ **Antes**: Proyecto 4 aparecía 6 veces
✅ **Ahora**: Cada proyecto aparece solo 1 vez

---

### EJEMPLO 2: Filtro '2007'
**Proyectos del ejercicio 2007:**
1. Proyecto 4: POR UN GUADALAJARA SIN BACHES (RECONSTRUCCIÓN)
2. Proyecto 6: MODERNIZACION CATASTRAL 2A ETAPA
3. Proyecto 8: EMPRENDE-GUADALAJARA
4. Proyecto 15: MODERNIZACION DE LA ADMINISTRACIÓN TRIBUTARIA
5. Proyecto 19: VIA RE-ACTIVA

**Nota**: Los resultados son similares al ejemplo 1 porque la mayoría de proyectos están en 2007 (226 proyectos).
Esto es **CORRECTO**, no es un error.

---

### EJEMPLO 3: Filtro 'OBRA'
**Proyectos con "OBRA" en la descripción:**
1. Proyecto 221: OBRA 14039ESC011/PR/14/E/SC/0007
2. Proyecto 222: OBRA 14039ESC022/PR/14/E/SC/0006
3. Proyecto 223: OBRA 14039ESC028/PR/14/E/SC/0004
4. Proyecto 224: OBRA 14039ESC033/PR/14/E/SC/0005
5. Proyecto 225: OBRA 14039EMF010/PR/14/E/MF/0003

✅ **Resultados DIFERENTES** a los ejemplos anteriores

---

### EJEMPLO 4: Filtro '6' (proyecto específico)
**Todas las instancias del proyecto 6:**
1. Ejercicio 2007, Proyecto 6: MODERNIZACION CATASTRAL 2A ETAPA
2. Ejercicio 2006, Proyecto 6: MODERNIZACION CATASTRAL 2A ETAPA
3. Ejercicio 2005, Proyecto 6: MODERNIZACION CATASTRAL 2A ETAPA

✅ Muestra el mismo proyecto en diferentes ejercicios

---

## EJEMPLOS ADICIONALES RECOMENDADOS

### Para ver proyectos del 2006:
**Filtro**: `2006`
**Resultado esperado**: 444 proyectos del ejercicio 2006

### Para buscar por texto:
- Filtro: `MODERNIZACION` - Proyectos de modernización
- Filtro: `GUADALAJARA` - Proyectos con Guadalajara en el nombre
- Filtro: `CATASTRAL` - Proyectos catastrales

### Para buscar proyectos específicos:
- Filtro: `15` - Proyecto 15 de todos los ejercicios
- Filtro: `44` - Proyecto 44 (I.P.C.)
- Filtro: `110` - Proyecto 110 (REMANENTES RAMO 33)

---

## ESTADÍSTICAS DE LA BASE DE DATOS

**Ejercicios disponibles**: 2007, 2006, 2005, 2004, 2003

**Proyectos por ejercicio**:
- 2007: 226 proyectos
- 2006: 444 proyectos
- 2005: 302 proyectos
- 2004: 1 proyecto
- 2003: 1 proyecto

**Total**: 974 proyectos únicos

---

## CAMBIOS TÉCNICOS

### Antes (con duplicados):
```sql
SELECT p.ejercicio, p.proyecto, ...
FROM comun.ta_proyectos p
LEFT JOIN comun.ta_proyecto_pres pp ...
WHERE p.ejercicio = 2007
ORDER BY p.ejercicio DESC
LIMIT 50;
```

### Después (sin duplicados):
```sql
SELECT
    p.ejercicio,
    p.proyecto,
    MAX(pp.dependencia) as dependencia,
    SUM(pp.presactual) as presactual,
    ...
FROM comun.ta_proyectos p
LEFT JOIN comun.ta_proyecto_pres pp ...
WHERE p.ejercicio = 2007
GROUP BY p.ejercicio, p.proyecto, p.descripcion
ORDER BY p.ejercicio DESC
LIMIT 50;
```

---

## ESTADO FINAL

✅ **CORREGIDO Y PROBADO**

- Cada proyecto aparece solo una vez
- Los filtros funcionan correctamente
- Los totales de presupuesto se suman correctamente
- Sin errores en la base de datos

El módulo `proyecfrm.vue` ahora funciona correctamente con diferentes filtros.

---

**Generado**: 2025-12-04
**Archivo**: recaudadora_proyecfrm_fixed.sql
**Estado**: ✅ DESPLEGADO Y VERIFICADO
