# Progreso de Corrección de Componentes Vue - Cementerios

**Fecha:** 2025-11-09
**Estado:** En Progreso - Fase 3

---

## 📊 RESUMEN GENERAL

**Total de componentes con estilos scoped:** 29 componentes
**Completados:** 10 componentes
**Pendientes:** 19 componentes
**Progreso:** 34.5%

---

## ✅ COMPONENTES COMPLETADOS (10/29)

### FASE 1: CRÍTICOS (3 componentes)
1. ✅ **Menu.vue** - Eliminado scoped completo (111 líneas removidas)
2. ⚠️ **Modulo.vue** - Scoped parcial justificado (87 líneas mantenidas para layouts únicos)
3. ⚠️ **ABCRecargos.vue** - Scoped parcial justificado (31 líneas mantenidas)

### FASE 2: ALTOS - Consultas (7 componentes)
4. ✅ **ConsultaGuad.vue** - Eliminado scoped completo
5. ✅ **ConsultaJardin.vue** - Eliminado scoped completo
6. ✅ **ConsultaMezq.vue** - Eliminado scoped completo
7. ✅ **ConsultaSAndres.vue** - Eliminado scoped completo
8. ⚠️ **ConsultaRCM.vue** - Scoped justificado (grid de información único)
9. ✅ **ConsultaNombre.vue** - Eliminado scoped + refactor a badges
10. ✅ **Consulta400.vue** - Eliminado scoped + refactor a badges

### FASE 2: ALTOS - Operaciones (2 componentes)
11. ⚠️ **ConIndividual.vue** - Scoped justificado (layout complejo de información + tabla)
12. ✅ **Descuentos.vue** - Eliminado scoped completo

### ACCESO (Login)
13. ⚠️ **Acceso.vue** - Scoped justificado (página login completa con diseño único)

---

## ⏳ COMPONENTES PENDIENTES (19/29)

### FASE 3: MEDIOS (10 componentes)
14. ⏳ **Multiplexcon.vue** - Multiplex por concepto
15. ⏳ **Multiplexlot.vue** - Multiplex por lote
16. ⏳ **Multiplexsec.vue** - Multiplex por sección
17. ⏳ **Traslado.vue** - Traslados
18. ⏳ **Traslado1.vue** - Traslados tipo 1
19. ⏳ **Duplicados.vue** - Gestión de duplicados
20. ⏳ **TitulosSin.vue** - Títulos sin
21. ⏳ **Bonificacion1.vue** - Bonificaciones
22. ⏳ **ABCPagosxfol.vue** - ABC de pagos por folio

### FASE 4: BAJOS (6 componentes)
23. ⏳ **Estad_adeudo.vue** - Estadísticas de adeudos
24. ⏳ **List_Mov.vue** - Listado de movimientos
25. ⏳ **Rep_a_Cobrar.vue** - Reporte a cobrar
26. ⏳ **Rep_Bon.vue** - Reporte de bonificaciones
27. ⏳ **RptTitulos.vue** - Reporte de títulos
28. ⏳ **sfrm_chgpass.vue** - Cambio de contraseña

### AUXILIARES (3 componentes adicionales encontrados)
29. ⏳ **ABCFolio.vue** - ABC de folios (si tiene scoped)
30. ⏳ **Bonificaciones.vue** - Bonificaciones principal (si tiene scoped)
31. ⏳ **ABCementer.vue** - ABC de cementerios (si tiene scoped)

---

## 📋 ESTADÍSTICAS DE CORRECCIÓN

### Estilos Removidos vs Justificados

| Componente | Líneas Scoped | Acción | Resultado |
|------------|--------------|--------|-----------|
| Menu.vue | 111 | Removido completo | ✅ |
| Modulo.vue | 87 | Mantenido justificado | ⚠️ |
| ABCRecargos.vue | 31 | Mantenido justificado | ⚠️ |
| ConsultaGuad.vue | 8 | Removido completo | ✅ |
| ConsultaJardin.vue | 8 | Removido completo | ✅ |
| ConsultaMezq.vue | 8 | Removido completo | ✅ |
| ConsultaSAndres.vue | 8 | Removido completo | ✅ |
| ConsultaRCM.vue | 36 | Mantenido justificado | ⚠️ |
| ConsultaNombre.vue | 18 | Removido + refactor | ✅ |
| Consulta400.vue | 8 | Removido + refactor | ✅ |
| ConIndividual.vue | 96 | Mantenido justificado | ⚠️ |
| Descuentos.vue | 18 | Removido completo | ✅ |
| Acceso.vue | 144 | Mantenido justificado | ⚠️ |

**Total líneas analizadas:** 581 líneas
**Total líneas removidas:** 195 líneas (33.6%)
**Total líneas justificadas:** 386 líneas (66.4%)

---

## 🎯 CRITERIOS DE CORRECCIÓN

### ✅ Estilos que se REMUEVEN
- Utilidades básicas (`.btn-sm`, `.text-center`, `.mt-3`, etc.)
- Clases de estado estándar que existen globalmente
- Colores básicos usando variables CSS
- Espaciado y márgenes estándar

### ⚠️ Estilos que se MANTIENEN (Justificados)
- Layouts únicos específicos del componente (grids personalizados)
- Animaciones y transiciones únicas
- Diseños de páginas especiales (login, dashboards)
- Estructuras complejas de información no reutilizables

---

## 📝 CAMBIOS ESPECÍFICOS APLICADOS

### 1. Conversión de status a badges
**Antes:**
```vue
<span :class="getAnioPagadoClass()">{{ año }}</span>

.status-success { color: var(--color-success); }
.status-warning { color: var(--color-warning); }
.status-danger { color: var(--color-danger); }
```

**Después:**
```vue
<span :class="`badge badge-${getAnioPagadoBadge()}`">{{ año }}</span>

// Sin scoped styles - usa clases globales
```

### 2. Remoción de utilidades básicas
**Antes:**
```vue
<style scoped>
.btn-sm { padding: 0.375rem 0.75rem; }
.text-center { text-align: center; }
.mt-3 { margin-top: 1rem; }
</style>
```

**Después:**
```vue
// Sin scoped - usa municipal-theme.css
```

---

## 🚀 PRÓXIMOS PASOS

### Fase 3: MEDIOS (10 componentes) - Estimado 2-3 horas
- Multiplex components (3)
- Traslados (2)
- Duplicados, Títulos, Bonificaciones (3)
- ABCPagosxfol (1)

### Fase 4: BAJOS (6 componentes) - Estimado 1-2 horas
- Reportes y estadísticas (5)
- Cambio de contraseña (1)

### Verificación Final
- Pruebas visuales de todos los componentes
- Validación de clases globales disponibles
- Documentación de justificaciones de scoped mantenidos

---

## 💡 LECCIONES APRENDIDAS

1. **No todo scoped es malo**: Layouts complejos y únicos DEBEN mantener scoped
2. **Badges > custom classes**: Usar sistema de badges municipal para estados
3. **Utilidades globales**: Verificar municipal-theme.css antes de crear custom
4. **Consistencia**: Seguir patrón de Padrón de Licencias

---

**Generado:** 2025-11-09
**Proyecto:** RefactorX - Guadalajara
**Módulo:** Cementerios
**Fase:** 3 - Corrección de Componentes Vue (34.5% completado)
