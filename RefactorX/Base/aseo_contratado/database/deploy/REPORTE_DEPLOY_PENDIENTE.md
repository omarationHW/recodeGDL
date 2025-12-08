# REPORTE: Deploy Pendiente de SPs - Aseo Contratado

**Fecha:** 2025-12-02
**Estado:** PENDIENTE DE EJECUCION

## Problema Detectado

El servidor PostgreSQL en `192.168.6.146:5432` tiene todas las conexiones ocupadas:

```
FATAL: remaining connection slots are reserved for roles with the SUPERUSER attribute
```

Esto significa que el parámetro `max_connections` está al límite y solo usuarios con SUPERUSER pueden conectarse.

## Soluciones

### Opción 1: Liberar conexiones
```sql
-- Ejecutar como superusuario (postgres)
SELECT pg_terminate_backend(pid)
FROM pg_stat_activity
WHERE state = 'idle'
AND query_start < NOW() - INTERVAL '5 minutes';
```

### Opción 2: Aumentar max_connections
Editar `postgresql.conf`:
```
max_connections = 200  # Incrementar de 100 a 200
```
Reiniciar PostgreSQL.

### Opción 3: Ejecutar con usuario superusuario
```bash
psql -h 192.168.6.146 -U postgres -d aseo_contratado -f DEPLOY_SPS_ASEO_CONTRATADO.sql
```

## Archivos para Deploy

Una vez disponible la conexión, ejecutar:

1. **Script SQL Principal:**
   ```
   RefactorX/Base/aseo_contratado/database/deploy/DEPLOY_SPS_ASEO_CONTRATADO.sql
   ```

2. **Script PHP de Deploy:**
   ```
   RefactorX/BackEnd/deploy_aseo_contratado_sps.php
   ```

## SPs a Crear (15 Total)

| # | Nombre SP | Descripción |
|---|-----------|-------------|
| 1 | sp_aseo_contratos_list | Listar contratos con filtros |
| 2 | sp_aseo_contratos_get | Obtener contrato por ID |
| 3 | sp_aseo_contratos_create | Crear contrato con pagos automáticos |
| 4 | sp_aseo_contratos_update | Actualizar datos de contrato |
| 5 | sp_aseo_contratos_baja | Dar de baja contrato |
| 6 | sp_aseo_contratos_buscar | Buscar contratos |
| 7 | sp_aseo_adeudos_vencidos | Consultar adeudos vencidos |
| 8 | sp_aseo_pago_registrar | Registrar pago |
| 9 | sp_aseo_tipos_aseo_list | Catálogo tipos de aseo |
| 10 | sp_aseo_empresas_list | Catálogo empresas |
| 11 | sp_aseo_zonas_list | Catálogo zonas |
| 12 | sp_aseo_unidades_list | Catálogo unidades recolección |
| 13 | sp_aseo_recaudadoras_list | Catálogo recaudadoras |
| 14 | sp_aseo_recargos_list | Catálogo recargos |
| 15 | sp_aseo_gastos_list | Catálogo gastos |
| 16 | sp_aseo_estado_cuenta | Estado de cuenta completo |

## Comando de Ejecución

```bash
# Opción 1: PHP
cd RefactorX/BackEnd
php deploy_aseo_contratado_sps.php

# Opción 2: psql directo
psql -h 192.168.6.146 -U refact -d aseo_contratado -f ../Base/aseo_contratado/database/deploy/DEPLOY_SPS_ASEO_CONTRATADO.sql
```

## Verificación Post-Deploy

```sql
-- Verificar SPs creados
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'aseo_contratado'
AND routine_name LIKE 'sp_aseo%'
ORDER BY routine_name;

-- Debe mostrar 15 stored procedures
```
