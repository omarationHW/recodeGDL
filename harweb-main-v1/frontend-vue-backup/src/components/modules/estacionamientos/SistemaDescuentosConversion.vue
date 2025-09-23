<template>
  <div class="sistema-descuentos-conversion">
    <!-- 🆕 COMPONENTE DE SISTEMAS MODERNOS -->
    <div class="alert alert-success mb-4">
      <h4 class="alert-heading">🆕 SISTEMAS MODERNOS - Estacionamientos</h4>
      <p class="mb-0">Nuevos sistemas de descuentos, conversión de procedimientos y funciones excluidas</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-cogs me-2 text-success"></i>
              Modernización de Estacionamientos
            </h2>
            <p class="text-muted mb-0">Descuentos inteligentes y conversión de procedimientos de pago</p>
          </div>
          <div class="badge badge-success">3 SISTEMAS NUEVOS</div>
        </div>
      </div>
    </div>

    <!-- Navegación por pestañas -->
    <ul class="nav nav-tabs nav-fill mb-4" id="sistemasTab" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="funciones-excluidas-tab" data-bs-toggle="tab" data-bs-target="#funciones-excluidas" type="button" role="tab">
          <i class="fas fa-times-circle me-2"></i>
          Funciones Excluidas
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="descuentos-tab" data-bs-toggle="tab" data-bs-target="#descuentos" type="button" role="tab">
          <i class="fas fa-percentage me-2"></i>
          Sistema Descuentos
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="conversion-tab" data-bs-toggle="tab" data-bs-target="#conversion" type="button" role="tab">
          <i class="fas fa-sync-alt me-2"></i>
          Conversión Procedimientos
        </button>
      </li>
    </ul>

    <!-- Contenido de las pestañas -->
    <div class="tab-content" id="sistemasTabContent">

      <!-- 1. Funciones Excluidas -->
      <div class="tab-pane fade show active" id="funciones-excluidas" role="tabpanel">
        <div class="card">
          <div class="card-header bg-danger text-white">
            <h5 class="mb-0">🚫 Funciones Excluidas del Sistema</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-danger">
              <h6 class="alert-heading">⚠️ Función Obsoleta Identificada</h6>
              <p class="mb-0">La siguiente función ha sido identificada como obsoleta y será removida del sistema</p>
            </div>

            <div class="table-responsive">
              <table class="table table-striped">
                <thead class="table-danger">
                  <tr>
                    <th width="5%">#</th>
                    <th width="30%">Función Obsoleta</th>
                    <th width="40%">Motivo de Exclusión</th>
                    <th width="15%">Estado Actual</th>
                    <th width="10%">Acción</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>1</strong></td>
                    <td>
                      <i class="fas fa-dollar-sign text-muted me-2"></i>
                      <strong>Públicos ingresos</strong>
                    </td>
                    <td>Sistema de manejo de ingresos públicos obsoleto que será reemplazado por sistema integral moderno con geolocalización, control por zona y reportes avanzados</td>
                    <td><span class="badge bg-warning">OBSOLETO</span></td>
                    <td>
                      <button class="btn btn-sm btn-danger" title="Marcar para remoción">
                        <i class="fas fa-trash"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <!-- Análisis Detallado -->
            <div class="row mt-4">
              <div class="col-md-6">
                <div class="card border-warning">
                  <div class="card-header bg-warning text-dark">
                    <h6 class="mb-0">🔍 Análisis de la Función Obsoleta</h6>
                  </div>
                  <div class="card-body">
                    <h6 class="text-primary">Públicos Ingresos</h6>
                    <p class="small mb-2"><strong>Problemas Actuales:</strong></p>
                    <ul class="small mb-3">
                      <li>Sistema de captura manual ineficiente</li>
                      <li>Falta de geolocalización de ingresos</li>
                      <li>Reportes limitados y no integrales</li>
                      <li>No considera zonas tarifarias</li>
                      <li>Proceso desactualizado sin automatización</li>
                      <li>Dificultad para conciliar por ubicación</li>
                    </ul>
                    <p class="small mb-1"><strong>Impacto de Remoción:</strong></p>
                    <p class="small text-success">Positivo - Será reemplazado por sistema moderno</p>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card border-success">
                  <div class="card-header bg-success text-white">
                    <h6 class="mb-0">🔄 Sistema de Reemplazo</h6>
                  </div>
                  <div class="card-body">
                    <h6 class="text-success">Sistema Integral Moderno</h6>
                    <p class="small mb-2"><strong>Nuevas Características:</strong></p>
                    <ul class="small mb-3">
                      <li>Captura automática georeferenciada</li>
                      <li>Control de ingresos por zona</li>
                      <li>Reportes en tiempo real con mapas</li>
                      <li>Integración con sistema de convenios</li>
                      <li>Dashboard con análisis visual</li>
                      <li>Exportación avanzada a Excel/PDF</li>
                      <li>Alertas automáticas por zona</li>
                      <li>Control de conciliación inteligente</li>
                    </ul>
                    <p class="small mb-1"><strong>Beneficio:</strong></p>
                    <p class="small text-success">Eficiencia 300% mayor</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Plan de Migración -->
            <div class="card mt-4">
              <div class="card-header bg-info text-white">
                <h6 class="mb-0">📋 Plan de Migración Específico</h6>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-4">
                    <h6 class="text-primary">Fase 1: Preparación</h6>
                    <ul class="list-unstyled">
                      <li><i class="fas fa-check text-success me-2"></i>Backup de datos de ingresos</li>
                      <li><i class="fas fa-check text-success me-2"></i>Mapeo de ubicaciones existentes</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Capacitación en nueva interfaz</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Pruebas de geolocalización</li>
                    </ul>
                  </div>
                  <div class="col-md-4">
                    <h6 class="text-warning">Fase 2: Transición</h6>
                    <ul class="list-unstyled">
                      <li><i class="fas fa-clock text-warning me-2"></i>Operación paralela (15 días)</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Validación cruzada por zona</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Ajustes de coordenadas</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Soporte a usuarios de campo</li>
                    </ul>
                  </div>
                  <div class="col-md-4">
                    <h6 class="text-success">Fase 3: Implementación</h6>
                    <ul class="list-unstyled">
                      <li><i class="fas fa-clock text-warning me-2"></i>Activación del nuevo sistema</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Desactivación de función obsoleta</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Documentación actualizada</li>
                      <li><i class="fas fa-clock text-warning me-2"></i>Evaluación de resultados</li>
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 2. Sistema de Descuentos -->
      <div class="tab-pane fade" id="descuentos" role="tabpanel">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">💰 Sistema Integral de Descuentos de Recargos y Multas</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-info">
              <h6 class="alert-heading">🆕 Sistema Moderno de Descuentos</h6>
              <p class="mb-0">Gestión automatizada de descuentos en recargos y multas con políticas configurables por zona</p>
            </div>

            <div class="row">
              <div class="col-md-6">
                <h6 class="text-info">Configuración de Políticas de Descuento</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Tipo de Descuento</label>
                  <select class="form-select">
                    <option>Pronto Pago (15 días)</option>
                    <option>Adulto Mayor (60+)</option>
                    <option>Persona con Discapacidad</option>
                    <option>Contribuyente Cumplido</option>
                    <option>Descuento por Zona</option>
                    <option>Campaña Especial</option>
                  </select>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Porcentaje de Descuento</label>
                      <div class="input-group">
                        <input type="number" class="form-control" step="0.01" max="100" placeholder="0.00">
                        <span class="input-group-text">%</span>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Aplica a</label>
                      <select class="form-select">
                        <option>Solo Recargos</option>
                        <option>Solo Multas</option>
                        <option>Ambos</option>
                        <option>Importe Principal</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Zona de Aplicación</label>
                      <select class="form-select">
                        <option>Todas las Zonas</option>
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
                      <label class="form-label">Vigencia</label>
                      <select class="form-select">
                        <option>Permanente</option>
                        <option>Temporal (fechas)</option>
                        <option>Por Campaña</option>
                        <option>Estacional</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Criterios de Elegibilidad</label>
                  <textarea class="form-control" rows="3" placeholder="Descripción de requisitos para aplicar el descuento..."></textarea>
                </div>
                <div class="form-check mb-3">
                  <input class="form-check-input" type="checkbox" id="descuentoAutomatico">
                  <label class="form-check-label" for="descuentoAutomatico">
                    Aplicación automática al cumplir criterios
                  </label>
                </div>
                <div class="d-flex gap-2">
                  <button class="btn btn-success"><i class="fas fa-plus"></i> Crear Política</button>
                  <button class="btn btn-primary"><i class="fas fa-calculator"></i> Simular Descuento</button>
                </div>
              </div>
              <div class="col-md-6">
                <h6 class="text-info">Políticas Activas por Zona</h6>
                <div class="table-responsive">
                  <table class="table table-sm">
                    <thead class="table-info">
                      <tr>
                        <th>Tipo</th>
                        <th>%</th>
                        <th>Zona</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td><small>Pronto Pago</small></td>
                        <td><strong>20%</strong></td>
                        <td><span class="badge bg-primary">Centro</span></td>
                        <td><span class="badge bg-success">Activa</span></td>
                        <td>
                          <button class="btn btn-xs btn-warning"><i class="fas fa-edit"></i></button>
                        </td>
                      </tr>
                      <tr>
                        <td><small>Adulto Mayor</small></td>
                        <td><strong>50%</strong></td>
                        <td><span class="badge bg-secondary">Todas</span></td>
                        <td><span class="badge bg-success">Activa</span></td>
                        <td>
                          <button class="btn btn-xs btn-warning"><i class="fas fa-edit"></i></button>
                        </td>
                      </tr>
                      <tr>
                        <td><small>Campaña 2024</small></td>
                        <td><strong>30%</strong></td>
                        <td><span class="badge bg-warning">Norte</span></td>
                        <td><span class="badge bg-warning">Temporal</span></td>
                        <td>
                          <button class="btn btn-xs btn-warning"><i class="fas fa-edit"></i></button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div class="alert alert-success mt-3">
                  <h6>📊 Estadísticas de Descuentos</h6>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Descuentos aplicados hoy:</span>
                    <strong>156</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Importe total descontado:</span>
                    <strong>$45,890.00</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Promedio por descuento:</span>
                    <strong>$294.17</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Efectividad de cobro:</span>
                    <strong class="text-success">+35%</strong>
                  </div>
                </div>

                <div class="card border-info mt-3">
                  <div class="card-header bg-info text-white py-2">
                    <h6 class="mb-0">🎯 Simulador de Descuentos</h6>
                  </div>
                  <div class="card-body p-3">
                    <div class="form-group mb-2">
                      <label class="form-label small">Importe Base</label>
                      <input type="number" class="form-control form-control-sm" placeholder="$0.00">
                    </div>
                    <div class="form-group mb-2">
                      <label class="form-label small">Recargos</label>
                      <input type="number" class="form-control form-control-sm" placeholder="$0.00">
                    </div>
                    <div class="form-group mb-2">
                      <label class="form-label small">Multas</label>
                      <input type="number" class="form-control form-control-sm" placeholder="$0.00">
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Tipo de Descuento</label>
                      <select class="form-select form-select-sm">
                        <option>Pronto Pago (20%)</option>
                        <option>Adulto Mayor (50%)</option>
                        <option>Discapacidad (50%)</option>
                      </select>
                    </div>
                    <button class="btn btn-info btn-sm w-100">
                      <i class="fas fa-calculator"></i> Calcular
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Reportes de Descuentos -->
            <div class="row mt-4">
              <div class="col-12">
                <div class="card bg-light">
                  <div class="card-body">
                    <h6 class="fw-bold text-dark mb-3">📈 Reportes de Descuentos Aplicados</h6>
                    <div class="row g-3">
                      <div class="col-md-3">
                        <button class="btn btn-outline-success w-100">
                          <i class="fas fa-file-excel me-2"></i>
                          <small>Descuentos por Zona</small>
                        </button>
                      </div>
                      <div class="col-md-3">
                        <button class="btn btn-outline-info w-100">
                          <i class="fas fa-file-excel me-2"></i>
                          <small>Análisis de Impacto</small>
                        </button>
                      </div>
                      <div class="col-md-3">
                        <button class="btn btn-outline-warning w-100">
                          <i class="fas fa-file-excel me-2"></i>
                          <small>Efectividad de Cobro</small>
                        </button>
                      </div>
                      <div class="col-md-3">
                        <button class="btn btn-outline-primary w-100">
                          <i class="fas fa-file-excel me-2"></i>
                          <small>Resumen Ejecutivo</small>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 3. Conversión de Procedimientos -->
      <div class="tab-pane fade" id="conversion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">🔄 Conversión de Procedimientos de Pago y Cálculo</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-success">
              <h6 class="alert-heading">🆕 Modernización de Procedimientos</h6>
              <p class="mb-0">Conversión completa de procedimientos de pago en caja y cálculo automatizado para revaluación de costos</p>
            </div>

            <div class="row">
              <div class="col-md-6">
                <h6 class="text-success">Conversión de Procedimientos de Pago en Caja</h6>
                <div class="card border-success">
                  <div class="card-header bg-success text-white py-2">
                    <h6 class="mb-0">💳 Nuevos Métodos de Pago</h6>
                  </div>
                  <div class="card-body">
                    <div class="d-flex align-items-center mb-3">
                      <div class="bg-success bg-opacity-10 rounded-3 p-2 me-3">
                        <i class="fas fa-credit-card text-success"></i>
                      </div>
                      <div>
                        <h6 class="mb-1">Pagos Electrónicos</h6>
                        <p class="small text-muted mb-0">Tarjetas de débito y crédito</p>
                      </div>
                      <div class="ms-auto">
                        <span class="badge bg-success">ACTIVO</span>
                      </div>
                    </div>
                    <div class="d-flex align-items-center mb-3">
                      <div class="bg-info bg-opacity-10 rounded-3 p-2 me-3">
                        <i class="fas fa-mobile-alt text-info"></i>
                      </div>
                      <div>
                        <h6 class="mb-1">Pagos Móviles</h6>
                        <p class="small text-muted mb-0">Código QR y aplicaciones</p>
                      </div>
                      <div class="ms-auto">
                        <span class="badge bg-info">NUEVO</span>
                      </div>
                    </div>
                    <div class="d-flex align-items-center mb-3">
                      <div class="bg-warning bg-opacity-10 rounded-3 p-2 me-3">
                        <i class="fas fa-university text-warning"></i>
                      </div>
                      <div>
                        <h6 class="mb-1">Transferencias Bancarias</h6>
                        <p class="small text-muted mb-0">SPEI y banca en línea</p>
                      </div>
                      <div class="ms-auto">
                        <span class="badge bg-warning">INTEGRADO</span>
                      </div>
                    </div>
                    <div class="d-flex align-items-center mb-3">
                      <div class="bg-primary bg-opacity-10 rounded-3 p-2 me-3">
                        <i class="fas fa-globe text-primary"></i>
                      </div>
                      <div>
                        <h6 class="mb-1">Portal Web</h6>
                        <p class="small text-muted mb-0">Pagos en línea 24/7</p>
                      </div>
                      <div class="ms-auto">
                        <span class="badge bg-primary">DISPONIBLE</span>
                      </div>
                    </div>
                  </div>
                </div>

                <div class="card border-info mt-3">
                  <div class="card-header bg-info text-white py-2">
                    <h6 class="mb-0">⚙️ Configuración de Caja</h6>
                  </div>
                  <div class="card-body">
                    <div class="form-group mb-3">
                      <label class="form-label small">Terminal de Punto de Venta</label>
                      <select class="form-select form-select-sm">
                        <option>Terminal 001 - Caja Centro</option>
                        <option>Terminal 002 - Caja Norte</option>
                        <option>Terminal 003 - Caja Sur</option>
                        <option>Móvil - Ejecutores</option>
                      </select>
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Métodos Habilitados</label>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="efectivo" checked>
                        <label class="form-check-label small" for="efectivo">Efectivo</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="tarjeta" checked>
                        <label class="form-check-label small" for="tarjeta">Tarjeta</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="movil" checked>
                        <label class="form-check-label small" for="movil">Pago Móvil</label>
                      </div>
                    </div>
                    <button class="btn btn-info btn-sm w-100">
                      <i class="fas fa-sync-alt"></i> Actualizar Configuración
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <h6 class="text-success">Cálculo para Revaluación de Costos</h6>
                <div class="card border-warning">
                  <div class="card-header bg-warning text-dark py-2">
                    <h6 class="mb-0">📊 Sistema de Revaluación Automática</h6>
                  </div>
                  <div class="card-body">
                    <div class="form-group mb-3">
                      <label class="form-label small">Tipo de Revaluación</label>
                      <select class="form-select form-select-sm">
                        <option>Anual (Base INPC)</option>
                        <option>Semestral</option>
                        <option>Por Zona Específica</option>
                        <option>Extraordinaria</option>
                      </select>
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Factor de Incremento</label>
                      <div class="input-group">
                        <input type="number" class="form-control form-control-sm" step="0.01" placeholder="0.00">
                        <span class="input-group-text">%</span>
                      </div>
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Fecha de Aplicación</label>
                      <input type="date" class="form-control form-control-sm">
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Zonas Afectadas</label>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="zonaCentro" checked>
                        <label class="form-check-label small" for="zonaCentro">Zona Centro</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="zonaNorte">
                        <label class="form-check-label small" for="zonaNorte">Zona Norte</label>
                      </div>
                      <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="zonaSur">
                        <label class="form-check-label small" for="zonaSur">Zona Sur</label>
                      </div>
                    </div>
                    <button class="btn btn-warning btn-sm w-100">
                      <i class="fas fa-calculator"></i> Calcular Revaluación
                    </button>
                  </div>
                </div>

                <div class="alert alert-warning mt-3">
                  <h6>📈 Resultados de Última Revaluación</h6>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Fecha:</span>
                    <strong>01/01/2024</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Factor aplicado:</span>
                    <strong>4.5%</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Estacionamientos afectados:</span>
                    <strong>1,245</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Incremento promedio:</span>
                    <strong>$127.50</strong>
                  </div>
                </div>
              </div>
            </div>

            <!-- Beneficios de la Conversión -->
            <div class="row mt-4">
              <div class="col-12">
                <div class="card bg-light">
                  <div class="card-body">
                    <h6 class="fw-bold text-dark mb-3">🎯 Beneficios de la Modernización</h6>
                    <div class="row g-3">
                      <div class="col-md-3">
                        <div class="text-center">
                          <div class="display-6 text-success">
                            <i class="fas fa-clock"></i>
                          </div>
                          <h6 class="text-success">Eficiencia</h6>
                          <p class="small text-muted">70% reducción en tiempo de procesamiento</p>
                        </div>
                      </div>
                      <div class="col-md-3">
                        <div class="text-center">
                          <div class="display-6 text-info">
                            <i class="fas fa-shield-alt"></i>
                          </div>
                          <h6 class="text-info">Seguridad</h6>
                          <p class="small text-muted">Eliminación de manejo de efectivo</p>
                        </div>
                      </div>
                      <div class="col-md-3">
                        <div class="text-center">
                          <div class="display-6 text-warning">
                            <i class="fas fa-chart-line"></i>
                          </div>
                          <h6 class="text-warning">Precisión</h6>
                          <p class="small text-muted">Cálculos automáticos sin errores</p>
                        </div>
                      </div>
                      <div class="col-md-3">
                        <div class="text-center">
                          <div class="display-6 text-primary">
                            <i class="fas fa-users"></i>
                          </div>
                          <h6 class="text-primary">Satisfacción</h6>
                          <p class="small text-muted">Mejor experiencia del usuario</p>
                        </div>
                      </div>
                    </div>
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
  name: 'SistemaDescuentosConversion'
}
</script>

<style scoped>
.sistema-descuentos-conversion {
  padding: 1rem;
}

.alert-success {
  border-left: 4px solid #28a745;
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

.display-6 {
  font-size: 2.5rem;
}

.btn-xs {
  padding: 0.125rem 0.25rem;
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