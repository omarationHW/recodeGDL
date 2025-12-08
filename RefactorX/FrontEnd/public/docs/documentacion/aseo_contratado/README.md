# Documentacion Consolidada - Modulo Aseo Contratado

Bienvenido a la documentacion tecnica consolidada del modulo **Aseo Contratado** del sistema RefactorX.

## Que encontraras aqui

Esta documentacion consolida tres tipos de documentos tecnicos para cada componente Vue.js del modulo:

1. **Analisis Tecnico** - Arquitectura, endpoints API, validaciones, estructura de datos
2. **Casos de Prueba** - Escenarios de testing, datos de entrada/salida, validaciones
3. **Casos de Uso** - Historias de usuario, flujos de interaccion, actores

## Como usar esta documentacion

### Para Desarrolladores

1. **Busca el componente** que necesitas consultar en el archivo [INDEX.md](./INDEX.md)
2. **Abre el archivo .md** correspondiente
3. **Consulta la seccion "Analisis Tecnico"** para entender:
   - Arquitectura del componente
   - Endpoints API disponibles
   - Estructura de datos
   - Validaciones y reglas de negocio
   - Ejemplos de eRequest/eResponse

### Para QA / Testers

1. **Localiza el componente** a probar en [INDEX.md](./INDEX.md)
2. **Revisa la seccion "Casos de Prueba"** que incluye:
   - Escenarios de prueba detallados
   - Datos de entrada esperados
   - Resultados esperados
   - Validaciones a verificar
   - Casos limite y errores

### Para Product Owners / Analistas

1. **Encuentra el componente** en [INDEX.md](./INDEX.md)
2. **Lee la seccion "Casos de Uso"** para comprender:
   - Historias de usuario
   - Flujos de trabajo
   - Actores involucrados
   - Interacciones con otros modulos

## Estructura de Archivos

Cada archivo de documentacion sigue este formato:

```markdown
# Documentacion Tecnica: [NombreComponente]

## Analisis Tecnico
[Contenido tecnico detallado]

## Casos de Prueba
[Escenarios y validaciones]

## Casos de Uso
[Historias de usuario y flujos]

---
**Componente:** `[NombreComponente].vue`
**Modulo:** `aseo_contratado`
```

## Navegacion Rapida

### Por Categoria

- **Catalogos (ABC)**: [INDEX.md#catalogos-abc](./INDEX.md#catalogos-abc)
- **Gestion de Contratos**: [INDEX.md#gestion-de-contratos](./INDEX.md#gestion-de-contratos)
- **Actualizaciones**: [INDEX.md#actualizaciones-de-contratos](./INDEX.md#actualizaciones-de-contratos)
- **Adeudos**: [INDEX.md#gestion-de-adeudos](./INDEX.md#gestion-de-adeudos)
- **Pagos**: [INDEX.md#gestion-de-pagos](./INDEX.md#gestion-de-pagos)
- **Reportes**: [INDEX.md#reportes](./INDEX.md#reportes)

### Componentes Mas Consultados

- [Contratos.md](./Contratos.md) - Gestion general de contratos
- [Adeudos_Pag.md](./Adeudos_Pag.md) - Pagos de adeudos
- [ABC_Recaudadoras.md](./ABC_Recaudadoras.md) - Catalogo de recaudadoras
- [Rep_PadronContratos.md](./Rep_PadronContratos.md) - Reporte padron

## Estadisticas

- **Total de componentes documentados**: 67
- **Total de archivos**: 117
- **Cobertura de documentacion**: 100%
- **Tamano total**: ~791 KB

## Archivos Especiales

- **INDEX.md** - Indice general con todos los componentes organizados por categoria
- **README.md** - Este archivo de ayuda
- **REPORTE_PROCESAMIENTO.md** - Reporte detallado del procesamiento de documentacion

## Convenciones

### Nomenclatura de Componentes

- `ABC_*` - Catalogos de mantenimiento (Alta, Baja, Cambio)
- `Contratos_*` - Operaciones sobre contratos
- `Adeudos_*` - Gestion de adeudos
- `Pagos_*` - Operaciones de pago
- `Rep_*` / `Rpt_*` - Reportes
- `Upd_*` - Actualizaciones masivas

### Iconografia en Documentacion

- ✓ Operacion exitosa
- ✗ Operacion fallida
- ⚠ Advertencia o caso especial
- ℹ Informacion adicional

## Soporte y Actualizaciones

Esta documentacion se genera a partir de archivos fuente ubicados en:
- `RefactorX\Base\aseo_contratado\docs\analisis\`
- `RefactorX\Base\aseo_contratado\docs\test-cases\`
- `RefactorX\Base\aseo_contratado\docs\use-cases\`

Para reportar errores o sugerir mejoras, contacta al equipo de desarrollo.

## Version

- **Version de Documentacion**: 1.0
- **Fecha de Generacion**: 2025-11-27
- **Modulo**: aseo_contratado
- **Sistema**: RefactorX - Guadalajara

---

**Proyecto RefactorX**
Sistema de Gestion Municipal - Modernizacion Tecnologica
