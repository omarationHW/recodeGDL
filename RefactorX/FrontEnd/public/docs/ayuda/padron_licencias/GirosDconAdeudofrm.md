# Reporte de Giros Comerciales con Adeudo

## Descripción General

### ¿Qué hace este módulo?
Genera un **reporte especializado que agrupa licencias con adeudos por tipo de giro comercial**. Permite identificar qué giros tienen mayor morosidad y cuántas licencias de cada giro adeudan desde un año específico.

### ¿Para qué sirve en el proceso administrativo?
- Identificar giros con mayor índice de morosidad
- Planificar estrategias de cobranza por sector económico
- Generar estadísticas de cumplimiento fiscal por giro
- Priorizar acciones de regularización por actividad comercial
- Presentar informes ejecutivos de cartera vencida segmentada

### ¿Quiénes lo utilizan?
- **Dirección de Ingresos**: Para análisis de recaudación
- **Departamento de Cobranza**: Para focalizar esfuerzos
- **Dirección General**: Para toma de decisiones estratégicas
- **Planeación**: Para estadísticas sectoriales

## Proceso Administrativo

**1. Captura de Año**
- Usuario ingresa el año desde el cual se consideran los adeudos
- Ejemplo: 2023 (mostrará licencias con adeudos desde 2023 hasta hoy)

**2. Generación del Reporte**
- Click en BitBtn1 "Generar"
- Sistema ejecuta query que:
  - Agrupa licencias por giro comercial
  - Cuenta cuántas licencias de cada giro tienen adeudo desde el año indicado
  - Ordena por número de licencias morosas (de mayor a menor)

**3. Visualización**
- Si encuentra registros: Imprime reporte automáticamente
- Si no encuentra: Mensaje "No se encontraron licencias..."

## Tablas de Base de Datos

### Tabla Principal
**buscaGiros** (Query) - Vista agrupada de licencias con adeudo por giro

### Tablas que Consulta
1. **licencias** - Licencias de funcionamiento
2. **c_giros** - Catálogo de giros comerciales
3. **detsal_lic** - Detalle de saldos para determinar adeudos

**Query aproximado:**
```sql
SELECT
  c.descripcion as giro,
  COUNT(DISTINCT l.id_licencia) as num_licencias_con_adeudo
FROM licencias l
INNER JOIN c_giros c ON c.id_giro = l.id_giro
INNER JOIN detsal_lic d ON d.id_licencia = l.id_licencia
WHERE d.cvepago = 0
  AND (SELECT MIN(x.axo) FROM detsal_lic x
       WHERE x.cvepago = 0 AND x.id_licencia = d.id_licencia) = [año_capturado]
GROUP BY c.descripcion
ORDER BY num_licencias_con_adeudo DESC
```

### Tablas que Modifica
**NINGUNA** - Módulo de solo consulta

## Stored Procedures
No utiliza stored procedures.

## Impacto y Repercusiones

### ¿Qué registros afecta?
**NINGUNO** - Solo consulta y reporta información

### ¿Qué cambios de estado provoca?
**NINGUNO** - Es un reporte de análisis

### ¿Qué documentos genera?

**Reporte Impreso (ppReport1):**
- Título: "Licencias con adeudo desde el año: [AÑO]"
- Columnas:
  - Descripción del giro comercial
  - Número de licencias con adeudo de ese giro
- Ordenado de mayor a menor morosidad
- Total de licencias morosas (sumatoria al final)
- Membrete municipal
- Fecha de generación
- Numeración de páginas

**Información del Reporte:**
- Permite identificar giros problemáticos
- Muestra patrones de morosidad por sector
- Base para campañas de regularización sectorizadas

### ¿Qué validaciones aplica?
1. Valida que se capture un año
2. Valida formato numérico del año
3. Valida que existan registros antes de imprimir

## Flujo de Trabajo

```
1. Usuario abre módulo
2. Sistema muestra campo de captura de año
3. Usuario captura año (ej: 2023)
4. Click en "Generar"
5. Sistema ejecuta query:
   - Busca licencias con adeudo desde ese año
   - Agrupa por giro
   - Cuenta licencias por giro
6. ¿Encontró registros?
   NO → Mensaje: "No se encontraron licencias..."
        Termina
   SÍ → Continúa
7. Configura etiqueta del reporte:
   "Licencias con adeudo desde el año: [AÑO]"
8. Imprime reporte automáticamente
9. FIN
```

## Notas Importantes

### Consideraciones Especiales

**1. Año "Desde"**
- Considera solo licencias cuyo primer adeudo sea del año indicado
- No incluye licencias con adeudos posteriores
- Ejemplo: Si se indica 2023:
  - Incluye: Licencia con adeudos 2023, 2024, 2025
  - NO incluye: Licencia con adeudos solo de 2024 y 2025 (su primer adeudo es 2024)

**2. Agrupación por Giro**
- Muestra conteo de licencias, no monto adeudado
- Útil para ver volumen de morosidad por sector
- No distingue entre pequeños y grandes adeudos

**3. Uso Estratégico**
- Identifica giros con problemas estructurales de pago
- Permite diseñar campañas de regularización focalizadas
- Base para programas de condonación o facilidades sectorizadas

**4. Impresión Automática**
- El reporte se imprime inmediatamente al generar
- No hay vista previa
- Pensado para generar reportes rápidos

### Restricciones
- Solo muestra giros CON adeudos (no muestra giros al corriente)
- No permite exportar a Excel (solo impresión)
- No permite modificar datos

### Permisos Necesarios
- Usuario válido del sistema
- Permiso de consulta en tablas de licencias y saldos
- Acceso a impresora para generar reporte

### Uso Recomendado
- Generación mensual para seguimiento de tendencias
- Antes de campañas de regularización para focalizar
- Para presentaciones ejecutivas sobre cartera vencida
- Identificación de giros que requieren atención especial
