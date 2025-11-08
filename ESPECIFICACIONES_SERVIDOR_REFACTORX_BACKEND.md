# ESPECIFICACIONES TÉCNICAS DEL SERVIDOR FÍSICO
## Sistema RefactorX BackEnd - API Genérico + Odoo
### Gobierno de Guadalajara

**Fecha de Análisis:** 05 de Noviembre de 2025
**Versión del Documento:** 2.0 (API Genérico + Odoo)
**Analista:** Claude AI - Anthropic
**Alcance:** API Genérico y API de Integración Odoo únicamente

---

## 📋 RESUMEN EJECUTIVO

Este documento especifica los requisitos técnicos del servidor físico para alojar **EXCLUSIVAMENTE** el sistema RefactorX BackEnd con enfoque en:

1. **API Genérico** - Endpoint único para ejecutar stored procedures en múltiples bases de datos
2. **API de Odoo** - Integración para consultas, pagos, cancelaciones y gestión de descuentos
3. **Autenticación JWT** - Sistema de tokens seguros para Odoo

**Tecnologías Core:**
- Laravel 12.0 (PHP 8.2)
- PostgreSQL 15/16
- Redis 7.0+
- Nginx + PHP-FPM

---

## 🔍 ANÁLISIS DEL SISTEMA

### Componentes del Sistema

#### 1. API Genérico (`/api/generic`)
**Controlador:** `GenericController.php` (380 líneas)

**Funcionalidad:**
- Ejecución dinámica de stored procedures
- Conexión a múltiples bases de datos PostgreSQL
- Soporte multi-schema (public, comun, informix)
- Paginación de resultados
- Validación de tipos de datos

**Bases de Datos Soportadas:**
- `padron_licencias` (principal)
- `aseo_contratado`
- `cementerio`
- `estacionamiento_exclusivo`
- `estacionamiento_publico`
- `mercados`
- `multas_reglamentos`
- `otras_obligaciones`
- `distribucion`

**Volumen Estimado:**
- 9 bases de datos PostgreSQL
- ~200-500 stored procedures (promedio)
- Request/Response JSON

#### 2. API de Odoo (`/api/odoo`)
**Controlador:** `OdooController.php` (908 líneas)

**Funciones Implementadas:**
- `Consulta` - Consulta origen de datos por referencia
- `DatosVarios` - Datos complementarios
- `AdeudoDetalle` - Detalle de adeudos
- `AdeudoDetalleInmovilizadores` - Infracciones de movilidad
- `Pago` - Registro de pagos
- `Cancelacion` - Cancelación de pagos
- `ConsCuenta` - Consulta cuenta predial
- `CatDescuentos` - Catálogo de descuentos
- `ListDescuentos` - Listado de descuentos aplicados
- `AltaDescuentos` - Alta de descuentos
- `CancelDescuentos` - Cancelación de descuentos
- `ConsDesctoTablet` - Consulta descuentos tablet
- `AltaDesctoTablet` - Alta descuentos tablet
- `FechasPendientesEl` - Fechas pendientes
- `PendientesXIntegrar` - Pendientes de integración
- `DetallesXIntegrar` - Detalles por integrar
- `ActualizarPendientes` - Actualización de pendientes
- `LicenciaVisor` - Visualización de licencias

**Módulos/Interfaces Soportadas:**
- Interfaces 8-15, 18-19, 22-23, 25, 30: Informix (padron_licencias)
- Interfaz 16: Movilidad (padron_movilidad)
- Interfaz 17: Obras (padron_obras)
- Interfaz 32: Infracciones (padron_infracciones)
- Interfaz 88: SICAM (padron_sicam)

**Bases de Datos Adicionales para Odoo:**
- `padron_movilidad`
- `padron_obras`
- `padron_infracciones`
- `padron_sicam`

#### 3. Autenticación JWT (`/api/odoo/auth/*`)
**Controlador:** `JwtAuthController.php` (380 líneas)

**Endpoints:**
- `/api/odoo/auth/token` - Generación de tokens
- `/api/odoo/auth/validate` - Validación de tokens
- `/api/odoo/auth/refresh` - Refrescar tokens
- `/api/odoo/auth/info` - Información de configuración

**Características:**
- Algoritmo HS256
- Expiración configurable (default 24 horas)
- Sistema de permisos granular
- Soporte Bearer token

---

## 🖥️ ESPECIFICACIONES DEL SERVIDOR FÍSICO

### 1. PROCESADOR (CPU)

**Especificación Mínima:**
- **Modelo:** Intel Xeon E-2236 / AMD Ryzen 9 5900X
- **Núcleos:** 6 cores físicos / 12 threads
- **Frecuencia Base:** 3.4 GHz mínimo
- **Caché L3:** 12 MB mínimo
- **TDP:** 80W

**Especificación Recomendada:**
- **Modelo:** Intel Xeon E-2388G / AMD Ryzen 9 5950X
- **Núcleos:** 8 cores físicos / 16 threads
- **Frecuencia Base:** 3.2 GHz
- **Frecuencia Turbo:** 5.0 GHz
- **Caché L3:** 16 MB

**Justificación:**
- Laravel procesa requests API concurrentes
- PostgreSQL ejecuta stored procedures complejos
- Redis para caché en memoria
- Estimado: 100-300 requests/segundo en picos

---

### 2. MEMORIA RAM

**Especificación Mínima:**
- **Capacidad:** 16 GB DDR4-2666 ECC
- **Configuración:** 2 x 8 GB
- **Tipo:** ECC Unbuffered (UDIMM)

**Especificación Recomendada:**
- **Capacidad:** 32 GB DDR4-3200 ECC
- **Configuración:** 2 x 16 GB o 4 x 8 GB
- **Tipo:** ECC Registered (RDIMM)
- **Velocidad:** 3200 MT/s

**Distribución de Memoria (32 GB):**
```
PostgreSQL 13 bases de datos:
  - Shared buffers: 8 GB
  - Work mem: 2 GB
  - Effective cache: 4 GB
  Subtotal: 14 GB

Laravel + PHP-FPM:
  - 80 workers x 16 MB: 1.3 GB
  - OPcache: 512 MB
  Subtotal: 2 GB

Redis Cache:
  - Sessions + cache: 2 GB

Sistema Operativo:
  - Ubuntu Server: 2 GB

Nginx + servicios:
  - 500 MB

Buffer disponible:
  - 11.5 GB (36% libre)

TOTAL: 32 GB
```

---

### 3. ALMACENAMIENTO

#### Configuración Óptima:

**Disco 1: Sistema + Aplicación**
- **Tipo:** SSD NVMe M.2
- **Capacidad:** 256 GB
- **Velocidad Lectura:** 3,500 MB/s
- **Velocidad Escritura:** 2,000 MB/s
- **Uso:**
  - Sistema operativo: 40 GB
  - Laravel + vendor: 15 GB
  - Logs: 30 GB
  - Swap: 16 GB
  - Libre: 155 GB

**Disco 2: Bases de Datos PostgreSQL**
- **Tipo:** SSD NVMe PCIe 3.0/4.0
- **Capacidad:** 1 TB
- **IOPS:** 500,000+ lectura / 300,000+ escritura
- **Velocidad Lectura:** 5,000 MB/s
- **Velocidad Escritura:** 4,000 MB/s
- **Resistencia:** 1,800+ TBW
- **Uso:**
  - 13 bases de datos PostgreSQL
  - Índices optimizados
  - WAL (Write-Ahead Log): 50 GB
  - Espacio datos: 400 GB (crecimiento 3 años)
  - Libre: 550 GB

**Disco 3: Backups (Opcional)**
- **Tipo:** HDD SATA 7200 RPM o SSD SATA
- **Capacidad:** 2 TB
- **Uso:**
  - Backups diarios PostgreSQL
  - Logs históricos
  - Archivos temporales

**RAID Recomendado:**
- RAID 1 para disco de base de datos (2 x 1 TB) = Alta disponibilidad

---

### 4. RED Y CONECTIVIDAD

**Interfaz de Red:**
- **Cantidad:** 2 puertos (redundancia con bonding/LACP)
- **Velocidad:** 1 Gigabit Ethernet (1GbE) - **SUFICIENTE**
- **Chipset:** Intel I350 / Realtek 8125
- **Opcional:** 10 Gigabit si hay alta transferencia de archivos

**Ancho de Banda Estimado:**
- Request API promedio: 5-10 KB
- Response promedio: 20-50 KB
- 200 requests/seg = 10 MB/s = 80 Mbps
- **1 Gbps es más que suficiente**

**Gestión Remota:**
- Puerto IPMI / iLO / iDRAC (recomendado)

---

### 5. FUENTE DE PODER (PSU)

**Especificación:**
- **Potencia:** 500W - 650W
- **Certificación:** 80 PLUS Gold o superior
- **Tipo:** Simple o redundante (2 x 500W)
- **Factor de Forma:** ATX / EPS12V

**Consumo Estimado:**
```
CPU (8 cores):        95W
RAM (32 GB):          25W
SSD NVMe (2):         15W
HDD/SSD (1):          8W
Tarjetas de red:      10W
Ventiladores:         15W
--------------------------------
TOTAL:               168W
Margen 3x:           504W (PSU 550W-650W ideal)
```

---

### 6. REFRIGERACIÓN

**CPU Cooler:**
- **Tipo:** Torre con 2 ventiladores 120mm o refrigeración líquida AIO 240mm
- **TDP Soportado:** 150W+
- **Ejemplos:** Noctua NH-U12S, Cooler Master Hyper 212

**Ventilación Chasis:**
- 3 ventiladores 120mm (2 entrada frontal, 1 salida trasera)
- Temperatura objetivo: <70°C en carga

---

### 7. CHASIS

**Especificación:**
- **Tipo:** Torre 4U Rack o Mid Tower desktop
- **Bahías:**
  - 2 x M.2 NVMe
  - 2 x 3.5" HDD
  - 2 x 2.5" SSD
- **Slots PCIe:** Mínimo 2 (expansión)
- **Filtros de polvo:** Removibles

---

### 8. TARJETA MADRE (MOTHERBOARD)

**Especificación:**
- **Socket:** LGA 1200 (Intel) / AM4 (AMD)
- **Chipset:** Intel C246 / AMD B550
- **Factor:** ATX o Micro-ATX
- **Slots RAM:** 4 slots DDR4 (hasta 128 GB)
- **Slots PCIe:** 2 x PCIe 3.0/4.0 x16
- **Conectores M.2:** 2 slots NVMe
- **Conectores SATA:** 4-6 puertos
- **Ethernet:** 2 x 1GbE integrado (preferible Intel)
- **BIOS:** UEFI

---

## 💻 SOFTWARE Y CONFIGURACIÓN

### Sistema Operativo

**Recomendación:** Ubuntu Server 24.04 LTS

**Alternativas:**
- Rocky Linux 9
- Debian 12

---

### Stack Completo

#### Runtime
```
PHP 8.2.x (con extensiones):
  - pdo_pgsql
  - mbstring
  - xml
  - curl
  - gd
  - zip
  - bcmath
  - intl
  - opcache (CRÍTICO)
  - redis

Node.js: 20 LTS
Composer: 2.7+
```

#### Servidor Web
```
Nginx 1.24+
  - Worker processes: 4-8 (según cores CPU)
  - Worker connections: 2048
  - Keepalive timeout: 65s

PHP-FPM 8.2
  - pm = dynamic
  - pm.max_children = 80
  - pm.start_servers = 20
  - pm.min_spare_servers = 10
  - pm.max_spare_servers = 40
  - pm.max_requests = 500
```

#### Base de Datos
```
PostgreSQL 16.x
  - shared_buffers = 8GB
  - effective_cache_size = 16GB
  - work_mem = 64MB
  - maintenance_work_mem = 1GB
  - max_connections = 200
  - checkpoint_completion_target = 0.9
  - wal_buffers = 16MB
  - random_page_cost = 1.1 (SSD)

Extensiones:
  - pg_stat_statements
  - auto_explain (producción)
```

#### Caché
```
Redis 7.2+
  - maxmemory = 2GB
  - maxmemory-policy = allkeys-lru
  - Persistencia: AOF (opcional)
```

#### Monitoreo
```
- Supervisor (gestión Laravel Queue)
- Monit (monitoreo servicios)
- fail2ban (seguridad)
```

---

## 📊 DIMENSIONAMIENTO POR CARGA

### Escenario 1: Carga Baja (50 requests/seg)
```
CPU:  20-30% utilización
RAM:  18 GB utilizados (de 32 GB)
IOPS: 10,000 lecturas / 3,000 escrituras
Red:  50 Mbps promedio
Response: <100ms (P95)
```

### Escenario 2: Carga Media (150 requests/seg)
```
CPU:  50-60% utilización
RAM:  24 GB utilizados
IOPS: 40,000 lecturas / 15,000 escrituras
Red:  200 Mbps promedio
Response: <200ms (P95)
```

### Escenario 3: Carga Alta (300 requests/seg)
```
CPU:  75-85% utilización
RAM:  28 GB utilizados
IOPS: 100,000 lecturas / 40,000 escrituras
Red:  500 Mbps promedio
Response: <500ms (P95)
```

### Escenario 4: Picos Extremos (500 requests/seg)
```
CPU:  90-95% utilización
RAM:  30 GB utilizados
IOPS: 200,000 lecturas / 80,000 escrituras
Red:  800 Mbps promedio
Response: <1000ms (P95)
⚠️ Considerar scale-out o upgrade
```

---

## 🔒 SEGURIDAD

### Seguridad de Red
- Firewall (UFW/iptables)
- Fail2ban (protección brute-force)
- Rate limiting Nginx (10 req/seg por IP)
- SSL/TLS con Let's Encrypt
- Segmentación VLAN (DB en red privada)

### Seguridad de Aplicación
- JWT con expiración 24h
- Validación de parámetros stored procedures
- Prepared statements (prevención SQL injection)
- CORS configurado
- Logs de auditoría activados

### Seguridad Física
- Servidor en data center controlado
- UPS con 30 min autonomía mínimo
- Temperatura 18-27°C
- Humedad 40-60%

---

## 💾 ESTRATEGIA DE BACKUPS

### Backups de PostgreSQL
```
Completos:
  - Diarios a las 02:00 AM
  - Retención: 30 días
  - Ubicación: Disco local + remoto

Incrementales:
  - WAL archiving continuo
  - PITR (Point-In-Time Recovery)
  - Retención: 7 días

Comandos:
  pg_dump (lógico)
  pg_basebackup (físico)
  Barman (automatización)
```

### Backups de Aplicación
```
Código:
  - Git repository (offsite)

Configuración:
  - .env files (cifrados)
  - Semanal

Logs:
  - Rotación diaria
  - Compresión gzip
  - Retención: 90 días
```

### Pruebas de Restauración
- Mensual: Verificar integridad
- Trimestral: Restauración completa en staging

---

## 📈 PROYECCIÓN DE CRECIMIENTO

### Año 1-2
- **Configuración actual suficiente**
- Monitoreo constante de métricas
- Optimización de queries lentos

### Año 3-4
- Posible upgrade a 64 GB RAM
- Considerar réplica read-only PostgreSQL
- Evaluar caché distribuido (Redis Cluster)

### Año 5+
- Arquitectura distribuida
- Load balancer (HAProxy/Nginx)
- PostgreSQL HA (Patroni + etcd)
- Separación API Gateway

---

## 💰 ESTIMACIÓN DE COSTOS (USD)

### Componentes del Servidor

| Componente | Especificación | Costo Aprox. |
|------------|----------------|--------------|
| CPU | Intel Xeon E-2388G / Ryzen 9 5950X | $500 - $800 |
| Motherboard | ASUS WS / Supermicro | $300 - $500 |
| RAM | 32 GB DDR4 ECC | $250 - $400 |
| SSD NVMe 1 | 256 GB (OS) | $40 - $60 |
| SSD NVMe 2 | 1 TB (DB) | $120 - $180 |
| HDD/SSD 3 | 2 TB (Backup) | $80 - $120 |
| Tarjeta Red | Dual 1GbE Intel | $100 - $150 |
| PSU | 650W 80+ Gold | $80 - $120 |
| Cooler CPU | Noctua NH-U12S | $70 - $100 |
| Chasis | 4U Rack / Tower | $150 - $300 |
| **TOTAL HARDWARE** | | **$1,690 - $2,730** |

### Infraestructura Adicional

| Item | Costo Aprox. |
|------|--------------|
| UPS 1500VA | $300 - $600 |
| Switch Gigabit 24 puertos | $150 - $300 |
| Rack 12U | $200 - $400 |
| Cableado Cat6/Cat6a | $100 - $200 |
| Instalación/Config | $800 - $1,500 |
| **TOTAL INFRAESTRUCTURA** | **$1,550 - $3,000** |

### **COSTO TOTAL ESTIMADO: $3,240 - $5,730 USD**

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### Fase 1: Hardware
- [ ] Adquirir componentes según especificaciones
- [ ] Ensamblar servidor
- [ ] Configurar BIOS/UEFI
- [ ] Instalar Ubuntu Server 24.04 LTS
- [ ] Configurar red (IP estática, DNS)
- [ ] Ejecutar pruebas de estrés (stress-ng, memtest86+)

### Fase 2: Software Base
- [ ] Actualizar sistema operativo
- [ ] Instalar PHP 8.2 con extensiones
- [ ] Instalar PostgreSQL 16
- [ ] Instalar Nginx
- [ ] Instalar PHP-FPM
- [ ] Instalar Redis 7
- [ ] Instalar Node.js 20 LTS
- [ ] Configurar firewall UFW
- [ ] Instalar fail2ban
- [ ] Instalar Supervisor

### Fase 3: Configuración PostgreSQL
- [ ] Crear 13 bases de datos
- [ ] Configurar postgresql.conf (optimizaciones)
- [ ] Configurar pg_hba.conf (autenticación)
- [ ] Crear usuario `refact`
- [ ] Importar stored procedures
- [ ] Configurar backups automáticos
- [ ] Activar pg_stat_statements

### Fase 4: Despliegue Aplicación
- [ ] Clonar repositorio RefactorX BackEnd
- [ ] Ejecutar `composer install --optimize-autoloader --no-dev`
- [ ] Ejecutar `npm install`
- [ ] Configurar `.env` (DB, Redis, JWT secret)
- [ ] Ejecutar `php artisan key:generate`
- [ ] Ejecutar `php artisan config:cache`
- [ ] Ejecutar `php artisan route:cache`
- [ ] Ejecutar `php artisan view:cache`
- [ ] Ejecutar `npm run build`
- [ ] Configurar permisos `storage` y `bootstrap/cache`
- [ ] Configurar cron para tareas Laravel

### Fase 5: Nginx + PHP-FPM
- [ ] Configurar virtual host Nginx
- [ ] Configurar PHP-FPM pool
- [ ] Configurar SSL/TLS (Let's Encrypt)
- [ ] Configurar rate limiting
- [ ] Configurar gzip compression
- [ ] Habilitar HTTP/2
- [ ] Probar configuración (`nginx -t`)

### Fase 6: Monitoreo y Seguridad
- [ ] Configurar Supervisor para queues Laravel
- [ ] Configurar Monit (opcional)
- [ ] Configurar fail2ban (SSH, Nginx)
- [ ] Configurar rotación de logs (logrotate)
- [ ] Configurar alertas (email/SMS)
- [ ] Implementar scripts de health check
- [ ] Documentar credenciales en vault seguro

### Fase 7: Testing
- [ ] Probar endpoint `/api/generic`
- [ ] Probar endpoint `/api/odoo`
- [ ] Probar autenticación JWT
- [ ] Ejecutar pruebas de carga (Apache Bench, K6)
- [ ] Verificar tiempos de respuesta <500ms
- [ ] Probar restauración de backups
- [ ] Validar logs de errores

### Fase 8: Documentación
- [ ] Documentar arquitectura del servidor
- [ ] Documentar procedimientos de mantenimiento
- [ ] Crear runbook de incidentes
- [ ] Documentar procedimientos de backup/restore
- [ ] Capacitar equipo de IT

---

## 🔧 COMANDOS ÚTILES

### Monitoreo en Tiempo Real
```bash
# CPU y RAM
htop

# Procesos PHP-FPM
watch -n 1 'ps aux | grep php-fpm | wc -l'

# Conexiones PostgreSQL
watch -n 1 'psql -U refact -c "SELECT count(*) FROM pg_stat_activity;"'

# Redis info
redis-cli INFO stats

# Nginx status
curl http://localhost/nginx_status

# Logs en tiempo real
tail -f /var/log/nginx/error.log
tail -f storage/logs/laravel.log
```

### Performance PostgreSQL
```sql
-- Queries lentos
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY mean_time DESC
LIMIT 10;

-- Tamaño de bases de datos
SELECT pg_database.datname,
       pg_size_pretty(pg_database_size(pg_database.datname))
FROM pg_database
ORDER BY pg_database_size(pg_database.datname) DESC;

-- Índices no utilizados
SELECT schemaname, tablename, indexname
FROM pg_stat_user_indexes
WHERE idx_scan = 0;
```

### Backups
```bash
# Backup completo PostgreSQL
pg_dumpall -U postgres > /backups/full_$(date +%Y%m%d).sql

# Backup individual
pg_dump -U refact padron_licencias > /backups/padron_$(date +%Y%m%d).sql

# Restaurar
psql -U refact padron_licencias < /backups/padron_20251105.sql
```

---

## 📞 MANTENIMIENTO RECOMENDADO

### Diario
- Revisar logs de errores Laravel/Nginx
- Monitorear uso de CPU/RAM/Disco
- Verificar servicios activos (Nginx, PHP-FPM, PostgreSQL, Redis)

### Semanal
- Análisis de queries lentos PostgreSQL
- Revisión de backups completados
- Limpieza de logs antiguos

### Mensual
- Actualizaciones de seguridad OS
- Optimización PostgreSQL (VACUUM, ANALYZE)
- Revisión capacidad de disco
- Análisis métricas de performance

### Trimestral
- Actualización de Laravel (minor versions)
- Actualización de dependencias PHP (composer update)
- Prueba de restauración de backups
- Auditoría de seguridad

---

## 📝 NOTAS FINALES

### Características Clave del Sistema

**API Genérico:**
- Endpoint único flexible
- Soporte multi-base de datos
- Ejecución dinámica de stored procedures
- 9 bases de datos principales

**API Odoo:**
- 18 funciones implementadas
- 5 módulos/interfaces soportadas (Informix, Movilidad, Obras, Infracciones, SICAM)
- Autenticación JWT robusta
- Integración para consultas y pagos

**Escalabilidad:**
- Arquitectura monolítica eficiente para 100-300 req/seg
- Posibilidad de scale-up (más RAM/CPU)
- Migración futura a microservicios si se requiere

### Recomendaciones Adicionales

1. **Monitoreo Proactivo:** Implementar alertas antes de alcanzar 80% de uso en cualquier recurso

2. **Caché Agresivo:** Redis para sesiones + resultados de queries frecuentes

3. **Optimización Queries:** Revisar y optimizar stored procedures lentos mensualmente

4. **Documentación Continua:** Mantener actualizado diagrama de arquitectura

5. **Plan de Contingencia:** RTO 4 horas, RPO 1 hora

---

**Documento Generado por Claude AI**
**Para:** Gobierno de Guadalajara - Sistemas RefactorX
**Alcance:** API Genérico + API Odoo + Autenticación JWT
**Confidencialidad:** Uso Interno
**Última Actualización:** 05 de Noviembre de 2025

---

## 🔗 REFERENCIAS

- Laravel 12 Documentation: https://laravel.com/docs/12.x
- PostgreSQL 16 Documentation: https://www.postgresql.org/docs/16/
- PHP 8.2 Documentation: https://www.php.net/manual/en/
- Redis 7 Documentation: https://redis.io/docs/
- Nginx Best Practices: https://www.nginx.com/resources/wiki/
- JWT Specification: https://jwt.io/

---

**FIN DEL DOCUMENTO**
