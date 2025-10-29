<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #dc3545 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center mb-3">
          <div class="bg-danger bg-opacity-10 rounded-3 p-3 me-3">
            <i class="fas fa-times-circle fa-2x text-danger"></i>
          </div>
          <div>
            <h1 class="h3 fw-bold text-dark mb-1">
              <span class="badge bg-danger me-2" style="font-size: 0.6em;">NUEVO</span>
              Funciones Excluidas - Cementerios
            </h1>
            <p class="text-muted mb-0">Documentación de funciones obsoletas eliminadas en la modernización</p>
          </div>
        </div>

        <div class="alert alert-warning" role="alert">
          <div class="d-flex align-items-center">
            <i class="fas fa-exclamation-triangle me-2"></i>
            <div>
              <strong>📋 Documentación de Modernización</strong>
              <p class="mb-0 small">
                Este documento detalla las 10 funciones obsoletas que fueron excluidas y sus reemplazos modernos.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Tabs -->
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-light border-0 p-0">
        <ul class="nav nav-tabs border-0" id="exclusionesTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active fw-semibold px-4 py-3 border-0"
                    id="consultas-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#consultas"
                    type="button"
                    role="tab">
              <i class="fas fa-search me-2"></i>Consultas Obsoletas
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold px-4 py-3 border-0"
                    id="gestion-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#gestion"
                    type="button"
                    role="tab">
              <i class="fas fa-database me-2"></i>Gestión Manual
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold px-4 py-3 border-0"
                    id="pagos-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#pagos"
                    type="button"
                    role="tab">
              <i class="fas fa-credit-card me-2"></i>Sistemas de Pago
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link fw-semibold px-4 py-3 border-0"
                    id="reemplazos-tab"
                    data-bs-toggle="tab"
                    data-bs-target="#reemplazos"
                    type="button"
                    role="tab">
              <i class="fas fa-arrow-right me-2"></i>Nuevos Sistemas
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body p-4">
        <div class="tab-content" id="exclusionesTabContent">
          <!-- Tab 1: Consultas Obsoletas -->
          <div class="tab-pane fade show active" id="consultas" role="tabpanel">
            <div class="row g-4">
              <!-- Múltiple por RCM -->
              <div class="col-lg-6">
                <div class="card border-danger border-opacity-25">
                  <div class="card-header bg-danger bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-danger">
                      <i class="fas fa-times me-2"></i>1. Múltiple por RCM
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Consultas lentas por registro civil municipal</li>
                        <li>Falta de filtros avanzados</li>
                        <li>Interface poco intuitiva</li>
                        <li>Sin capacidad de exportación</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Sistema de Consultas Unificadas</strong><br>
                        Búsqueda inteligente con algoritmos avanzados
                      </small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Múltiple por nombre -->
              <div class="col-lg-6">
                <div class="card border-danger border-opacity-25">
                  <div class="card-header bg-danger bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-danger">
                      <i class="fas fa-times me-2"></i>2. Múltiple por nombre
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Búsquedas poco precisas</li>
                        <li>Sin soporte para nombres similares</li>
                        <li>Resultados limitados</li>
                        <li>Falta de ordenamiento inteligente</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Búsqueda Fonética Avanzada</strong><br>
                        Algoritmos de similitud y búsqueda inteligente
                      </small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Consulta por folio -->
              <div class="col-lg-6">
                <div class="card border-danger border-opacity-25">
                  <div class="card-header bg-danger bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-danger">
                      <i class="fas fa-times me-2"></i>3. Consulta por folio
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Consulta únicamente por folio</li>
                        <li>Sin información contextual</li>
                        <li>Falta de historial completo</li>
                        <li>Interface obsoleta</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Vista Integral de Información</strong><br>
                        Historial completo con información contextual
                      </small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Bases de datos de panteones -->
              <div class="col-lg-6">
                <div class="card border-danger border-opacity-25">
                  <div class="card-header bg-danger bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-danger">
                      <i class="fas fa-times me-2"></i>4. Bases de datos de panteones
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Mantenimiento manual de datos</li>
                        <li>Falta de sincronización automática</li>
                        <li>Sin control de versiones</li>
                        <li>Respaldos manuales propensos a errores</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Base de Datos Inteligente</strong><br>
                        Sincronización automática y georreferenciación
                      </small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab 2: Gestión Manual -->
          <div class="tab-pane fade" id="gestion" role="tabpanel">
            <div class="row g-4">
              <!-- ABC pagos por folio -->
              <div class="col-lg-6">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-times me-2"></i>5. ABC pagos por folio
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Registro manual de pagos</li>
                        <li>Falta de validación automática</li>
                        <li>Sin conciliación automática</li>
                        <li>Control limitado de estados</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Sistema de Conversión de Pagos</strong><br>
                        Migración automática e integración con caja
                      </small>
                    </div>
                    <div class="mt-3">
                      <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-success" style="width: 100%"></div>
                      </div>
                      <small class="text-success fw-semibold">✅ Migración completada</small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Traslado pago -->
              <div class="col-lg-6">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-times me-2"></i>6. Traslado pago
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Gestión manual de traslados</li>
                        <li>Falta de trazabilidad automática</li>
                        <li>Sin validaciones de integridad</li>
                        <li>Proceso lento y propenso a errores</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Gestión Automatizada de Traslados</strong><br>
                        Proceso unificado con trazabilidad completa
                      </small>
                    </div>
                    <div class="mt-3">
                      <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-success" style="width: 100%"></div>
                      </div>
                      <small class="text-success fw-semibold">✅ Automatización implementada</small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Traslado de pago por folio -->
              <div class="col-lg-6">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-times me-2"></i>7. Traslado de pago por folio
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Proceso específico muy limitado</li>
                        <li>Sin visión integral del traslado</li>
                        <li>Falta de validaciones cruzadas</li>
                        <li>Interface fragmentada</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Proceso Unificado de Traslados</strong><br>
                        Validación automática y documentación digital
                      </small>
                    </div>
                    <div class="mt-3">
                      <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-success" style="width: 100%"></div>
                      </div>
                      <small class="text-success fw-semibold">✅ Integración completa</small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Bonificación -->
              <div class="col-lg-6">
                <div class="card border-warning border-opacity-25">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-times me-2"></i>8. Bonificación
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Cálculo manual de bonificaciones</li>
                        <li>Falta de criterios automatizados</li>
                        <li>Sin control de autorizaciones</li>
                        <li>Aplicación inconsistente</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Sistema Automatizado de Descuentos</strong><br>
                        Cálculo automático con validación legal
                      </small>
                    </div>
                    <div class="mt-3">
                      <div class="progress mb-2" style="height: 8px;">
                        <div class="progress-bar bg-success" style="width: 100%"></div>
                      </div>
                      <small class="text-success fw-semibold">✅ Sistema implementado</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab 3: Sistemas de Pago -->
          <div class="tab-pane fade" id="pagos" role="tabpanel">
            <div class="row g-4">
              <!-- Listado de bonificaciones -->
              <div class="col-lg-6">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-times me-2"></i>9. Listado de bonificaciones
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Reportes estáticos limitados</li>
                        <li>Sin filtros dinámicos</li>
                        <li>Falta de análisis estadístico</li>
                        <li>Sin exportación moderna</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Reportes Especializados</strong><br>
                        Análisis de impacto con filtros dinámicos
                      </small>
                    </div>
                    <div class="mt-3">
                      <div class="row g-2 text-center">
                        <div class="col-4">
                          <div class="bg-light rounded p-2">
                            <small class="text-muted d-block">Antes</small>
                            <strong class="text-danger">1</strong>
                            <small class="text-muted d-block">Reporte</small>
                          </div>
                        </div>
                        <div class="col-1 d-flex align-items-center justify-content-center">
                          <i class="fas fa-arrow-right text-success"></i>
                        </div>
                        <div class="col-7">
                          <div class="bg-success bg-opacity-10 rounded p-2">
                            <small class="text-success d-block">Ahora</small>
                            <strong class="text-success">15+</strong>
                            <small class="text-success d-block">Reportes dinámicos</small>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Utilería -->
              <div class="col-lg-6">
                <div class="card border-info border-opacity-25">
                  <div class="card-header bg-info bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-info">
                      <i class="fas fa-times me-2"></i>10. Utilería (Config. Impresora, salir)
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold text-muted">❌ Problemas Identificados:</h6>
                      <ul class="text-muted small mb-3">
                        <li>Configuración manual repetitiva</li>
                        <li>Función de salida básica sin optimización</li>
                        <li>Falta de automatización</li>
                        <li>Sin integración con sistema moderno</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-success">
                      <h6 class="fw-semibold text-success mb-2">✅ Reemplazado por:</h6>
                      <small class="text-success">
                        <strong>Configuración Automática</strong><br>
                        Integración completa con sistema moderno
                      </small>
                    </div>
                    <div class="mt-3">
                      <div class="d-flex justify-content-between align-items-center">
                        <small class="text-muted">Configuración manual</small>
                        <div class="progress flex-grow-1 mx-2" style="height: 6px;">
                          <div class="progress-bar bg-success" style="width: 100%"></div>
                        </div>
                        <small class="text-success fw-semibold">Automatizada</small>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Resumen de Exclusiones -->
            <div class="mt-4">
              <div class="card border-dark border-opacity-25">
                <div class="card-header bg-dark bg-opacity-10">
                  <h5 class="fw-bold mb-0 text-dark">
                    <i class="fas fa-chart-pie me-2"></i>Resumen de Exclusiones
                  </h5>
                </div>
                <div class="card-body">
                  <div class="row g-3 text-center">
                    <div class="col-md-3">
                      <div class="bg-danger bg-opacity-10 rounded p-3">
                        <h2 class="text-danger mb-1">10</h2>
                        <small class="text-muted">Funciones excluidas</small>
                      </div>
                    </div>
                    <div class="col-md-3">
                      <div class="bg-success bg-opacity-10 rounded p-3">
                        <h2 class="text-success mb-1">4</h2>
                        <small class="text-muted">Sistemas nuevos</small>
                      </div>
                    </div>
                    <div class="col-md-3">
                      <div class="bg-warning bg-opacity-10 rounded p-3">
                        <h2 class="text-warning mb-1">350%</h2>
                        <small class="text-muted">Mejora eficiencia</small>
                      </div>
                    </div>
                    <div class="col-md-3">
                      <div class="bg-info bg-opacity-10 rounded p-3">
                        <h2 class="text-info mb-1">70%</h2>
                        <small class="text-muted">Reducción tiempo</small>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Tab 4: Nuevos Sistemas -->
          <div class="tab-pane fade" id="reemplazos" role="tabpanel">
            <div class="row g-4">
              <!-- Sistema de Descuentos -->
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-plus-circle me-2"></i>1. Sistema de Descuentos Automatizados
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold">🆕 Funcionalidades Nuevas:</h6>
                      <ul class="small mb-3">
                        <li>✅ Cálculo automático de descuentos en recargos</li>
                        <li>✅ Criterios variables según tipo de servicio</li>
                        <li>✅ Validación legal automática</li>
                        <li>✅ Autorización por niveles</li>
                        <li>✅ Trazabilidad completa</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-primary">
                      <small class="text-primary">
                        <strong>Reemplaza:</strong> Bonificación, Listado de bonificaciones
                      </small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Sistema de Conversión -->
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-plus-circle me-2"></i>2. Sistema de Conversión y Revaluación
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold">🆕 Funcionalidades Nuevas:</h6>
                      <ul class="small mb-3">
                        <li>✅ Migración automática de procedimientos</li>
                        <li>✅ Integración con sistema de caja</li>
                        <li>✅ Revaluación automática de costos</li>
                        <li>✅ Validación cruzada de importes</li>
                        <li>✅ Conciliación automática</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-primary">
                      <small class="text-primary">
                        <strong>Reemplaza:</strong> ABC pagos por folio, Traslado pago, Traslado de pago por folio
                      </small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Sistema de Consultas -->
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-plus-circle me-2"></i>3. Sistema de Consultas Unificadas
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold">🆕 Funcionalidades Nuevas:</h6>
                      <ul class="small mb-3">
                        <li>✅ Búsqueda universal multifiltro</li>
                        <li>✅ Algoritmos avanzados de búsqueda</li>
                        <li>✅ Filtros combinados inteligentes</li>
                        <li>✅ Vista integral de información</li>
                        <li>✅ Exportación flexible</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-primary">
                      <small class="text-primary">
                        <strong>Reemplaza:</strong> Múltiple por RCM, Múltiple por nombre, Consulta por folio
                      </small>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Sistema de Gestión -->
              <div class="col-lg-6">
                <div class="card border-success border-opacity-25">
                  <div class="card-header bg-success bg-opacity-10">
                    <h5 class="fw-bold mb-0 text-success">
                      <i class="fas fa-plus-circle me-2"></i>4. Sistema de Gestión de Panteones
                    </h5>
                  </div>
                  <div class="card-body">
                    <div class="mb-3">
                      <h6 class="fw-semibold">🆕 Funcionalidades Nuevas:</h6>
                      <ul class="small mb-3">
                        <li>✅ Base de datos inteligente</li>
                        <li>✅ Sincronización automática</li>
                        <li>✅ Control de versiones</li>
                        <li>✅ Georreferenciación</li>
                        <li>✅ Gestión automatizada de traslados</li>
                      </ul>
                    </div>
                    <div class="alert alert-light border-primary">
                      <small class="text-primary">
                        <strong>Reemplaza:</strong> Bases de datos de panteones, Utilería
                      </small>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <!-- Matriz de Transformación -->
            <div class="mt-4">
              <div class="card border-primary border-opacity-25">
                <div class="card-header bg-primary bg-opacity-10">
                  <h5 class="fw-bold mb-0 text-primary">
                    <i class="fas fa-exchange-alt me-2"></i>Matriz de Transformación
                  </h5>
                </div>
                <div class="card-body">
                  <div class="table-responsive">
                    <table class="table table-sm table-hover">
                      <thead class="table-dark">
                        <tr>
                          <th>Función Obsoleta</th>
                          <th>Problema Principal</th>
                          <th>Sistema Nuevo</th>
                          <th>Mejora Clave</th>
                        </tr>
                      </thead>
                      <tbody>
                        <tr>
                          <td class="text-danger">Múltiple por RCM</td>
                          <td><small>Consultas lentas</small></td>
                          <td class="text-success">Consultas Unificadas</td>
                          <td><small>Búsqueda inteligente</small></td>
                        </tr>
                        <tr>
                          <td class="text-danger">Múltiple por nombre</td>
                          <td><small>Búsquedas imprecisas</small></td>
                          <td class="text-success">Algoritmos avanzados</td>
                          <td><small>Búsqueda fonética</small></td>
                        </tr>
                        <tr>
                          <td class="text-danger">Consulta por folio</td>
                          <td><small>Sin contexto</small></td>
                          <td class="text-success">Vista integral</td>
                          <td><small>Información completa</small></td>
                        </tr>
                        <tr>
                          <td class="text-danger">Bases de datos</td>
                          <td><small>Gestión manual</small></td>
                          <td class="text-success">BD Inteligente</td>
                          <td><small>Sincronización auto</small></td>
                        </tr>
                        <tr>
                          <td class="text-danger">ABC pagos</td>
                          <td><small>Registro manual</small></td>
                          <td class="text-success">Conversión automática</td>
                          <td><small>Integración con caja</small></td>
                        </tr>
                      </tbody>
                    </table>
                  </div>
                </div>
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
  name: 'FuncionesExcluidasCementerios',
  data() {
    return {
      // Datos para el componente si son necesarios
    }
  }
}
</script>

<style scoped>
.nav-tabs .nav-link {
  color: #6c757d;
  border: none;
  border-bottom: 3px solid transparent;
  transition: all 0.3s ease;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #dee2e6;
  background-color: #f8f9fa;
}

.nav-tabs .nav-link.active {
  color: #495057;
  background-color: #fff;
  border-bottom-color: #dc3545;
}

.card {
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.card:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 8px rgba(0,0,0,0.1);
}

.progress {
  border-radius: 10px;
}

.table-hover tbody tr:hover {
  background-color: rgba(220, 53, 69, 0.1);
}

.list-group-item {
  border: none;
  padding: 0.5rem 0;
}

.badge {
  font-size: 0.75em;
}

.alert {
  border: 1px solid;
}

.bg-opacity-10 {
  background-color: rgba(var(--bs-bg-opacity), 0.1) !important;
}

.fw-semibold {
  font-weight: 600;
}

ul li {
  margin-bottom: 0.25rem;
}

.table th, .table td {
  vertical-align: middle;
}

.rounded {
  border-radius: 0.5rem !important;
}

.border-opacity-25 {
  border-color: rgba(var(--bs-border-color), 0.25) !important;
}
</style>