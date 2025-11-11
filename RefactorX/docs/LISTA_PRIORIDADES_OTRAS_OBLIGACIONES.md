# LISTA DE PRIORIDADES - OTRAS OBLIGACIONES

**Fecha:** 2025-11-09
**Módulo:** otras_obligaciones
**Total componentes:** 13

---

## CRITERIOS DE PRIORIZACIÓN

1. **P1 - CRÍTICA:** Funcionalidad bloqueante, alto tráfico
2. **P2 - ALTA:** Funcionalidad core, uso frecuente
3. **P3 - MEDIA:** Reportes, consultas, CRUD secundario
4. **P4 - BAJA:** Utilerías, administración

---

## COMPONENTES POR PRIORIDAD

### P3 - MEDIA (13 componentes)

#### BATCH 1 - CONSULTAS Y REPORTES (6 componentes)

| # | Componente | Descripción | SPs | CSS Inline | Estado |
|---|------------|-------------|-----|------------|--------|
| 1 | **GConsulta2.vue** | Consulta general de concesiones con búsqueda múltiple | 7 | 18 | PENDIENTE |
| 2 | **RConsulta.vue** | Reporte de consulta de concesiones | 5 | 14 | PENDIENTE |
| 3 | **AuxRep.vue** | Auxiliar de reportes de padrón | 3 | 8 | PENDIENTE |
| 4 | **RAdeudos.vue** | Reporte de adeudos por local | 3 | 12 | PENDIENTE |
| 5 | **RAdeudos_OpcMult.vue** | Reporte de adeudos con opciones múltiples (Pagar/Condonar/Cancelar) | 5 | 10 | PENDIENTE |
| 6 | **GRep_Padron.vue** | Generador de reporte de padrón | 5 | 12 | PENDIENTE |

**Subtotal Batch 1:** 28 SPs, 74 estilos inline

#### BATCH 2 - CRUD (3 componentes)

| # | Componente | Descripción | SPs | CSS Inline | Estado |
|---|------------|-------------|-----|------------|--------|
| 7 | **RNuevos.vue** | Alta de nuevas concesiones | 3 | 15 | PENDIENTE |
| 8 | **RActualiza.vue** | Actualización de concesiones existentes | 3 | 11 | PENDIENTE |
| 9 | **RBaja.vue** | Baja de concesiones | 4 | 9 | PENDIENTE |

**Subtotal Batch 2:** 10 SPs, 35 estilos inline

#### BATCH 3 - FACTURACIÓN Y CATÁLOGOS (4 componentes)

| # | Componente | Descripción | SPs | CSS Inline | Estado |
|---|------------|-------------|-----|------------|--------|
| 10 | **RFacturacion.vue** | Reporte de facturación | 1 | 7 | PENDIENTE |
| 11 | **Etiquetas.vue** | Administración de etiquetas de columnas | 3 | 13 | PENDIENTE |
| 12 | **CargaCartera.vue** | Carga de cartera vencida | 3 | 10 | PENDIENTE |
| 13 | **CargaValores.vue** | Carga de valores y tarifas | 2 | 8 | PENDIENTE |

**Subtotal Batch 3:** 9 SPs, 38 estilos inline

---

## CONSOLIDADO

| Prioridad | Componentes | SPs Únicos | SPs Totales | Estilos Inline | Badge-info |
|-----------|-------------|------------|-------------|----------------|------------|
| **P3 - MEDIA** | 13 | 38 | 42 | 156 | 26 |

---

## SPs CONSOLIDADOS (42 totales, 38 únicos)

### CRÍTICOS (15 SPs)
1. sp_otras_oblig_buscar_coincide - GConsulta2
2. sp_otras_oblig_buscar_cont - GConsulta2
3. sp_otras_oblig_buscar_adeudos - GConsulta2
4. sp_otras_oblig_buscar_totales - GConsulta2
5. sp_otras_oblig_get_concesion_by_control - RConsulta
6. sp_otras_oblig_busca_cont - RAdeudos
7. sp_otras_oblig_busca_adeudos_01 - RAdeudos
8. sp_otras_oblig_busca_adeudos_02 - RAdeudos
9. sp_otras_oblig_get_adeudos - RAdeudos_OpcMult
10. sp_otras_oblig_execute_opc - RAdeudos_OpcMult
11. sp_otras_oblig_create_local - RNuevos
12. sp_otras_oblig_actualizar_concesion - RActualiza
13. sp_otras_oblig_cancelar_local - RBaja
14. sp_otras_oblig_carga_cartera - CargaCartera

### ALTOS (16 SPs)
15. sp_otras_oblig_get_etiquetas - GConsulta2
16. sp_otras_oblig_get_tablas - GConsulta2
17. sp_otras_oblig_buscar_pagados - GConsulta2
18. sp_otras_oblig_get_fecha_limite - RConsulta
19. sp_otras_oblig_get_padron - AuxRep
20. sp_otras_oblig_search_local - RAdeudos_OpcMult
21. sp_otras_oblig_check_control - RNuevos
22. sp_otras_oblig_verificar_pagos - RActualiza
23. sp_otras_oblig_verificar_adeudos - RBaja
24. sp_otras_oblig_verificar_adeudos_post - RBaja
25. sp_otras_oblig_get_rfacturacion_report - RFacturacion
26. sp_otras_oblig_get_unidades - CargaCartera
27. sp_otras_oblig_insert_valores - CargaValores
28. sp_otras_oblig_get_padron_con_adeudos - GRep_Padron
29. sp_otras_oblig_get_padron_adeudos_detalle - GRep_Padron

### MEDIOS (7 SPs)
30. sp_otras_oblig_get_vigencias - AuxRep
31. sp_otras_oblig_print_padron - AuxRep
32. sp_otras_oblig_get_recaudadoras - RAdeudos_OpcMult
33. sp_otras_oblig_get_cajas - RAdeudos_OpcMult
34. sp_otras_oblig_get_tipo_local - RNuevos
35. sp_otras_oblig_get_etiquetas_by_tabla - Etiquetas
36. sp_otras_oblig_update_etiquetas - Etiquetas
37. sp_otras_oblig_get_ejercicios - CargaCartera

### REUTILIZADOS (4 instancias)
- sp_otras_oblig_buscar_adeudos (usado en GConsulta2 y RConsulta)
- sp_otras_oblig_buscar_totales (usado en GConsulta2 y RConsulta)
- sp_otras_oblig_buscar_pagados (usado en GConsulta2 y RConsulta)
- sp_otras_oblig_get_concesion_by_control (usado en RConsulta y RActualiza/RBaja)

---

## ORDEN DE IMPLEMENTACIÓN

### Fase 1: SPs CRÍTICOS (Semana 1-2)
Crear los 15 SPs críticos que bloquean funcionalidad core

### Fase 2: SPs ALTOS (Semana 3-4)
Crear los 16 SPs de prioridad alta

### Fase 3: SPs MEDIOS (Semana 5)
Crear los 7 SPs de prioridad media

### Fase 4: Refactorización Vue
- **Semana 6:** Batch 1 (GConsulta2, RConsulta, AuxRep, RAdeudos, RAdeudos_OpcMult, GRep_Padron)
- **Semana 7:** Batch 2 (RNuevos, RActualiza, RBaja)
- **Semana 8:** Batch 3 (RFacturacion, Etiquetas, CargaCartera, CargaValores)

### Fase 5: Testing y QA (Semana 9)
Testing integral y correcciones

---

## DEPENDENCIAS

### Por Componente:
1. **GConsulta2** → Depende de: t_34_datos, t_34_adeudos, t_34_pagos
2. **RConsulta** → Depende de: GConsulta2 (SPs reutilizados)
3. **AuxRep** → Depende de: t_34_datos
4. **RAdeudos** → Depende de: t_34_datos, t_34_adeudos
5. **RAdeudos_OpcMult** → Depende de: RAdeudos, catálogos
6. **GRep_Padron** → Depende de: AuxRep (SPs reutilizados)
7. **RNuevos** → Depende de: catálogos
8. **RActualiza** → Depende de: RNuevos, RConsulta
9. **RBaja** → Depende de: RActualiza
10. **RFacturacion** → Depende de: t_34_adeudos
11. **Etiquetas** → Depende de: t_34_tablas
12. **CargaCartera** → Depende de: t_34_unidades, t_34_costos
13. **CargaValores** → Depende de: CargaCartera

---

## NOTAS IMPORTANTES

- Template de referencia: `Rubros.vue`
- Todos los componentes deben seguir los 15 estándares UI/UX
- Checklist de 15 items de validación obligatorio
- Documentación en 4 MDs por componente
- 0 estilos inline al finalizar
- 100% badges badge-purple (no badge-info)

---

**Última actualización:** 2025-11-09
**Responsable:** MEGA-AGENTE P3
**Versión:** 1.0
