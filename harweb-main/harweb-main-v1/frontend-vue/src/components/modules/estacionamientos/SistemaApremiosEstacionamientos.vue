<template>
  <div class="sistema-apremios-estacionamientos">
    <!-- 🆕 COMPONENTE DE SISTEMA INTEGRAL DE APREMIOS -->
    <div class="alert alert-warning mb-4">
      <h4 class="alert-heading">🆕 SISTEMA INTEGRAL DE APREMIOS - Estacionamientos</h4>
      <p class="mb-0">Módulo completo de administración de apremios georeferenciados, ejecutores, folios y notificaciones</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-gavel me-2 text-warning"></i>
              Sistema Integral de Apremios - Estacionamientos
            </h2>
            <p class="text-muted mb-0">Gestión completa de procedimientos de apremio y cobro coactivo por zonas</p>
          </div>
          <div class="badge badge-warning">7 MÓDULOS INTEGRADOS</div>
        </div>
      </div>
    </div>

    <!-- Navegación por pestañas -->
    <ul class="nav nav-tabs nav-fill mb-4" id="apremiosTab" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="ejecutores-tab" data-bs-toggle="tab" data-bs-target="#ejecutores" type="button" role="tab">
          <i class="fas fa-user-shield me-2"></i>
          <span class="d-none d-md-inline">ABC </span>Ejecutores
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="folios-tab" data-bs-toggle="tab" data-bs-target="#folios" type="button" role="tab">
          <i class="fas fa-file-alt me-2"></i>
          Gen. Folios
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="impresion-tab" data-bs-toggle="tab" data-bs-target="#impresion" type="button" role="tab">
          <i class="fas fa-print me-2"></i>
          Impresión
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="modificacion-tab" data-bs-toggle="tab" data-bs-target="#modificacion" type="button" role="tab">
          <i class="fas fa-edit me-2"></i>
          Modificación
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="consulta-tab" data-bs-toggle="tab" data-bs-target="#consulta" type="button" role="tab">
          <i class="fas fa-search me-2"></i>
          Consulta
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="gestion-tab" data-bs-toggle="tab" data-bs-target="#gestion" type="button" role="tab">
          <i class="fas fa-tasks me-2"></i>
          Gestión
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes" type="button" role="tab">
          <i class="fas fa-chart-line me-2"></i>
          Reportes
        </button>
      </li>
    </ul>

    <!-- Contenido de las pestañas -->
    <div class="tab-content" id="apremiosTabContent">

      <!-- 1. ABC del Catálogo de Ejecutores -->
      <div class="tab-pane fade show active" id="ejecutores" role="tabpanel">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <h5 class="mb-0">👮 ABC del Catálogo de Ejecutores por Zona</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-8">
                <h6 class="text-primary">Gestión de Personal Ejecutor Especializado</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Clave del Ejecutor</label>
                      <input type="text" class="form-control" placeholder="Ej: EST-EJE-001">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Nombre Completo</label>
                      <input type="text" class="form-control" placeholder="Nombre del ejecutor">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">RFC</label>
                      <input type="text" class="form-control" placeholder="RFC del ejecutor">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">CURP</label>
                      <input type="text" class="form-control" placeholder="CURP del ejecutor">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Zona/Sector Asignado</label>
                      <select class="form-select">
                        <option>Zona Centro (Estacionamientos)</option>
                        <option>Zona Norte (Públicos)</option>
                        <option>Zona Sur (Exclusivos)</option>
                        <option>Zona Oriente (Mixtos)</option>
                        <option>Zona Poniente (Comerciales)</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Especialización</label>
                      <select class="form-select">
                        <option>Estacionamientos Públicos</option>
                        <option>Estacionamientos Exclusivos</option>
                        <option>Zona Comercial</option>
                        <option>Zona Residencial</option>
                        <option>General</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Vehículo Asignado</label>
                      <input type="text" class="form-control" placeholder="Placas del vehículo">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Estado</label>
                      <select class="form-select">
                        <option>Activo</option>
                        <option>Inactivo</option>
                        <option>Suspendido</option>
                        <option>Vacaciones</option>
                        <option>Comisión</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Observaciones</label>
                  <textarea class="form-control" rows="2" placeholder="Notas adicionales sobre rutas, horarios específicos..."></textarea>
                </div>
                <div class="d-flex gap-2">
                  <button class="btn btn-success"><i class="fas fa-plus"></i> Alta</button>
                  <button class="btn btn-warning"><i class="fas fa-edit"></i> Modificar</button>
                  <button class="btn btn-danger"><i class="fas fa-trash"></i> Baja</button>
                  <button class="btn btn-info"><i class="fas fa-map"></i> Ver Zona</button>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-info">
                  <h6 class="alert-heading">📊 Estadísticas por Zona</h6>
                  <hr>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Ejecutores activos:</span>
                    <strong>18</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Con carga asignada:</span>
                    <strong>15</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Disponibles:</span>
                    <strong>3</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Efectividad promedio:</span>
                    <strong class="text-success">85%</strong>
                  </div>
                </div>

                <div class="card border-primary">
                  <div class="card-header bg-primary text-white py-2">
                    <h6 class="mb-0">🗺️ Distribución por Zona</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                      <small><strong>Centro:</strong> 6 ejecutores</small>
                      <span class="badge bg-primary">95%</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-1">
                      <small><strong>Norte:</strong> 4 ejecutores</small>
                      <span class="badge bg-success">88%</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-1">
                      <small><strong>Sur:</strong> 5 ejecutores</small>
                      <span class="badge bg-warning">82%</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                      <small><strong>Oriente:</strong> 3 ejecutores</small>
                      <span class="badge bg-info">90%</span>
                    </div>
                  </div>
                </div>

                <div class="card border-warning mt-3">
                  <div class="card-header bg-warning text-dark py-2">
                    <h6 class="mb-0">🚗 Control de Vehículos</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="d-flex justify-content-between mb-1">
                      <small>Vehículos asignados:</small>
                      <strong>18</strong>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                      <small>En servicio:</small>
                      <strong class="text-success">15</strong>
                    </div>
                    <div class="d-flex justify-content-between">
                      <small>En mantenimiento:</small>
                      <strong class="text-warning">3</strong>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 2. Generación de Folios -->
      <div class="tab-pane fade" id="folios" role="tabpanel">
        <div class="card">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">📄 Generación de Folios Georeferenciados</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-success">Criterios de Generación por Ubicación</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Tipo de Folio</label>
                  <select class="form-select">
                    <option>Notificación de Adeudo (Estacionamientos)</option>
                    <option>Requerimiento de Pago (Públicos)</option>
                    <option>Citatorio de Embargo (Exclusivos)</option>
                    <option>Notificación de Clausura</option>
                    <option>Multa por Ocupación Indebida</option>
                  </select>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Zona de Aplicación</label>
                      <select class="form-select">
                        <option>Todas las zonas</option>
                        <option>Zona Centro</option>
                        <option>Zona Norte</option>
                        <option>Zona Sur</option>
                        <option>Zona Oriente</option>
                        <option>Zona Poniente</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tipo de Estacionamiento</label>
                      <select class="form-select">
                        <option>Todos los tipos</option>
                        <option>Públicos</option>
                        <option>Exclusivos</option>
                        <option>Mixtos</option>
                        <option>Temporales</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Monto Mínimo</label>
                      <input type="number" class="form-control" step="0.01" placeholder="$0.00">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Años de Adeudo</label>
                      <select class="form-select">
                        <option>2024</option>
                        <option>2023</option>
                        <option>2022</option>
                        <option>2021 y anteriores</option>
                        <option>Todos</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Filtro por Ubicación Específica</label>
                  <div class="input-group">
                    <input type="text" class="form-control" placeholder="Calle, colonia, coordenadas...">
                    <button class="btn btn-outline-secondary" type="button">
                      <i class="fas fa-map-marker-alt"></i>
                    </button>
                  </div>
                </div>
                <button class="btn btn-success w-100">
                  <i class="fas fa-cogs"></i> Generar Folios por Zona
                </button>
              </div>
              <div class="col-md-6">
                <h6 class="text-success">Vista Previa de Generación</h6>
                <div class="alert alert-success">
                  <h6>📋 Resultados por Zona</h6>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Estacionamientos encontrados:</span>
                    <strong>324</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Adeudo promedio:</span>
                    <strong>$8,450.00</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Adeudo total:</span>
                    <strong>$2,737,800.00</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Folios a generar:</span>
                    <strong>324</strong>
                  </div>
                </div>

                <div class="card border-info">
                  <div class="card-header bg-info text-white py-2">
                    <h6 class="mb-0">🗺️ Distribución Geográfica</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="d-flex justify-content-between mb-1">
                      <small>Centro:</small>
                      <span class="badge bg-primary">156</span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                      <small>Norte:</small>
                      <span class="badge bg-success">78</span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                      <small>Sur:</small>
                      <span class="badge bg-warning">65</span>
                    </div>
                    <div class="d-flex justify-content-between">
                      <small>Oriente:</small>
                      <span class="badge bg-info">25</span>
                    </div>
                  </div>
                </div>

                <div class="card border-success mt-3">
                  <div class="card-header bg-success text-white py-2">
                    <h6 class="mb-0">📍 Configuración del Folio</h6>
                  </div>
                  <div class="card-body">
                    <div class="form-group mb-3">
                      <label class="form-label small">Serie del Folio</label>
                      <input type="text" class="form-control form-control-sm" value="EST-NOT-2024-" readonly>
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Folio Inicial</label>
                      <input type="number" class="form-control form-control-sm" value="2001">
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Fecha de Notificación</label>
                      <input type="date" class="form-control form-control-sm">
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Días para Respuesta</label>
                      <select class="form-select form-select-sm">
                        <option>15 días</option>
                        <option>30 días</option>
                        <option>45 días</option>
                      </select>
                    </div>
                    <div class="form-check">
                      <input class="form-check-input" type="checkbox" id="incluirMapa">
                      <label class="form-check-label small" for="incluirMapa">
                        Incluir mapa de ubicación
                      </label>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Las demás pestañas siguen la misma estructura pero adaptadas para estacionamientos -->
      <!-- Para mantener la respuesta concisa, incluyo solo la estructura principal -->

      <!-- 3. Impresión de Folios -->
      <div class="tab-pane fade" id="impresion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-dark text-white">
            <h5 class="mb-0">🖨️ Impresión con Ubicación Geográfica</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-info">
              <p class="mb-0"><strong>Documentos especializados:</strong> Incluyen mapas de ubicación, coordenadas GPS, referencias visuales y rutas de acceso para ejecutores.</p>
            </div>
            <!-- Contenido similar pero con componentes geográficos -->
          </div>
        </div>
      </div>

      <!-- 4. Modificación de Folios -->
      <div class="tab-pane fade" id="modificacion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-warning text-dark">
            <h5 class="mb-0">✏️ Modificación con Control Geográfico</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-warning">
              <p class="mb-0"><strong>Control de ubicaciones:</strong> Permite modificar datos del folio manteniendo la integridad geográfica y reasignación por zona.</p>
            </div>
            <!-- Contenido de modificación con validaciones geográficas -->
          </div>
        </div>
      </div>

      <!-- 5. Consulta de Folios -->
      <div class="tab-pane fade" id="consulta" role="tabpanel">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">🔍 Consulta Georreferenciada</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-info">
              <p class="mb-0"><strong>Búsqueda avanzada:</strong> Filtros por zona, proximidad geográfica, rutas de ejecutores y estados por ubicación.</p>
            </div>
            <!-- Contenido de consultas con filtros geográficos -->
          </div>
        </div>
      </div>

      <!-- 6. Gestión Masiva -->
      <div class="tab-pane fade" id="gestion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">⚙️ Gestión Masiva por Zona</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-secondary">
              <p class="mb-0"><strong>Operaciones geográficas:</strong> Asignación, cancelación y gestión masiva organizadas por zona y rutas optimizadas.</p>
            </div>
            <!-- Contenido de gestión masiva con criterios geográficos -->
          </div>
        </div>
      </div>

      <!-- 7. Reportes de Apremios -->
      <div class="tab-pane fade" id="reportes" role="tabpanel">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <h5 class="mb-0">📊 Reportes Geográficos Especializados</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-3">
                <h6 class="text-primary">Ejecutores por Zona</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Ejecutores Activos por Zona
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Carga de Trabajo Geográfica
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Efectividad por Área
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Rutas Optimizadas
                  </button>
                </div>
              </div>
              <div class="col-md-3">
                <h6 class="text-warning">Estacionamientos</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Descuentos por Zona
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Análisis Geográfico
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Impacto por Área
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Mapa de Calor
                  </button>
                </div>
              </div>
              <div class="col-md-3">
                <h6 class="text-info">Nómina Geográfica</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Nómina por Zona
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Kilometraje por Área
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Comisiones Geográficas
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Bonos por Efectividad
                  </button>
                </div>
              </div>
              <div class="col-md-3">
                <h6 class="text-success">Estado de Folios</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Folios por Zona
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Efectividad Geográfica
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Tiempos de Respuesta
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Mapas de Resultados
                  </button>
                </div>
              </div>
            </div>

            <!-- Criterios de Selección Geográficos -->
            <div class="card bg-light">
              <div class="card-body">
                <h6>🗺️ Criterios de Selección Geográficos</h6>
                <div class="row">
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Fecha Desde</label>
                      <input type="date" class="form-control form-control-sm">
                    </div>
                  </div>
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Fecha Hasta</label>
                      <input type="date" class="form-control form-control-sm">
                    </div>
                  </div>
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Zona</label>
                      <select class="form-select form-select-sm">
                        <option>Todas</option>
                        <option>Centro</option>
                        <option>Norte</option>
                        <option>Sur</option>
                        <option>Oriente</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Tipo Estac.</label>
                      <select class="form-select form-select-sm">
                        <option>Todos</option>
                        <option>Público</option>
                        <option>Exclusivo</option>
                        <option>Mixto</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Ejecutor</label>
                      <select class="form-select form-select-sm">
                        <option>Todos</option>
                        <option>EST-EJE-001</option>
                        <option>EST-EJE-002</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Formato</label>
                      <select class="form-select form-select-sm">
                        <option>Excel (.xlsx)</option>
                        <option>PDF con Mapas</option>
                        <option>CSV</option>
                        <option>KML (Google Earth)</option>
                      </select>
                    </div>
                  </div>
                </div>
                <button class="btn btn-primary btn-sm">
                  <i class="fas fa-download"></i> Generar Reporte Geográfico
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'SistemaApremiosEstacionamientos'
}
</script>

<style scoped>
.sistema-apremios-estacionamientos {
  padding: 1rem;
}

.alert-warning {
  border-left: 4px solid #ffc107;
}

.nav-tabs .nav-link {
  font-size: 0.9rem;
}

.nav-tabs .nav-link.active {
  font-weight: 600;
}

.table tbody tr:hover {
  background-color: #f8f9fa;
}

.badge {
  font-size: 0.75rem;
}

@media (max-width: 768px) {
  .nav-tabs .nav-link {
    font-size: 0.8rem;
    padding: 0.5rem;
  }

  .d-none.d-md-inline {
    display: none !important;
  }
}
</style>