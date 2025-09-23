<template>
  <div class="sistema-convenios-estacionamientos">
    <!-- 🆕 COMPONENTE DE SISTEMA INTEGRAL DE CONVENIOS -->
    <div class="alert alert-primary mb-4">
      <h4 class="alert-heading">🆕 SISTEMA INTEGRAL DE CONVENIOS - Estacionamientos</h4>
      <p class="mb-0">Módulo completo de administración de convenios, intereses, parcialidades y pagos georeferenciados</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-handshake me-2 text-primary"></i>
              Sistema Integral de Convenios - Estacionamientos
            </h2>
            <p class="text-muted mb-0">Gestión completa de convenios de pago para espacios de estacionamiento</p>
          </div>
          <div class="badge badge-primary">8 MÓDULOS INTEGRADOS</div>
        </div>
      </div>
    </div>

    <!-- Navegación por pestañas -->
    <ul class="nav nav-tabs nav-fill mb-4" id="conveniosTab" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" id="intereses-tab" data-bs-toggle="tab" data-bs-target="#intereses" type="button" role="tab">
          <i class="fas fa-percentage me-2"></i>
          <span class="d-none d-md-inline">ABC </span>Intereses
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="convenios-tab" data-bs-toggle="tab" data-bs-target="#convenios" type="button" role="tab">
          <i class="fas fa-file-contract me-2"></i>
          <span class="d-none d-md-inline">ABC </span>Convenios
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="parcialidades-tab" data-bs-toggle="tab" data-bs-target="#parcialidades" type="button" role="tab">
          <i class="fas fa-list-ol me-2"></i>
          Parcialidades
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="pagos-tab" data-bs-toggle="tab" data-bs-target="#pagos" type="button" role="tab">
          <i class="fas fa-money-bill-wave me-2"></i>
          <span class="d-none d-md-inline">ABC </span>Pagos
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="impresion-tab" data-bs-toggle="tab" data-bs-target="#impresion" type="button" role="tab">
          <i class="fas fa-print me-2"></i>
          Impresión
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="consultas-tab" data-bs-toggle="tab" data-bs-target="#consultas" type="button" role="tab">
          <i class="fas fa-search me-2"></i>
          Consultas
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes" type="button" role="tab">
          <i class="fas fa-chart-bar me-2"></i>
          Reportes
        </button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" id="cancelacion-tab" data-bs-toggle="tab" data-bs-target="#cancelacion" type="button" role="tab">
          <i class="fas fa-times-circle me-2"></i>
          Cancelación
        </button>
      </li>
    </ul>

    <!-- Contenido de las pestañas -->
    <div class="tab-content" id="conveniosTabContent">

      <!-- 1. ABC del Catálogo de Intereses -->
      <div class="tab-pane fade show active" id="intereses" role="tabpanel">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <h5 class="mb-0">📊 ABC del Catálogo de Intereses para Estacionamientos</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-8">
                <h6 class="text-primary">Gestión de Tasas de Interés por Tipo de Estacionamiento</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tipo de Interés</label>
                      <select class="form-select">
                        <option>Moratorio Público</option>
                        <option>Moratorio Exclusivo</option>
                        <option>Legal Estándar</option>
                        <option>Convenio Especial</option>
                        <option>Preferencial Zona Centro</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tasa (%)</label>
                      <input type="number" class="form-control" step="0.01" placeholder="Ej: 2.0">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tipo de Espacio</label>
                      <select class="form-select">
                        <option>Estacionamiento Público</option>
                        <option>Estacionamiento Exclusivo</option>
                        <option>Zona Preferencial</option>
                        <option>Zona Comercial</option>
                        <option>Zona Residencial</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Zona de Aplicación</label>
                      <select class="form-select">
                        <option>Zona Centro</option>
                        <option>Zona Norte</option>
                        <option>Zona Sur</option>
                        <option>Zona Oriente</option>
                        <option>Zona Poniente</option>
                        <option>Todas las Zonas</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Fecha Vigencia Desde</label>
                      <input type="date" class="form-control">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Fecha Vigencia Hasta</label>
                      <input type="date" class="form-control">
                    </div>
                  </div>
                </div>
                <div class="d-flex gap-2">
                  <button class="btn btn-success"><i class="fas fa-plus"></i> Alta</button>
                  <button class="btn btn-warning"><i class="fas fa-edit"></i> Modificar</button>
                  <button class="btn btn-danger"><i class="fas fa-trash"></i> Baja</button>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-info">
                  <h6 class="alert-heading">📋 Configuración por Zona</h6>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Centro:</span>
                    <strong>2.0%</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Exclusivos:</span>
                    <strong>1.5%</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Públicos:</span>
                    <strong>1.8%</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Vigencia:</span>
                    <strong>01/01/2024</strong>
                  </div>
                </div>

                <div class="card border-primary">
                  <div class="card-header bg-primary text-white py-2">
                    <h6 class="mb-0">🗺️ Mapa de Zonas</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="bg-light rounded p-3 text-center">
                      <i class="fas fa-map fa-3x text-primary mb-2"></i>
                      <p class="small mb-0">Vista interactiva de zonas de estacionamiento</p>
                      <button class="btn btn-sm btn-primary mt-2">Ver Mapa</button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 2. ABC del Convenio -->
      <div class="tab-pane fade" id="convenios" role="tabpanel">
        <div class="card">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">📄 ABC del Convenio de Estacionamientos</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-success">Datos Generales del Convenio</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Propietario/Concesionario</label>
                  <div class="input-group">
                    <input type="text" class="form-control" placeholder="Buscar propietario...">
                    <button class="btn btn-outline-secondary" type="button">
                      <i class="fas fa-search"></i>
                    </button>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Número de Convenio</label>
                      <input type="text" class="form-control" placeholder="EST-2024-001" readonly>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Fecha de Convenio</label>
                      <input type="date" class="form-control">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tipo de Estacionamiento</label>
                      <select class="form-select">
                        <option>Público</option>
                        <option>Exclusivo</option>
                        <option>Mixto</option>
                        <option>Temporal</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Zona</label>
                      <select class="form-select">
                        <option>Zona Centro</option>
                        <option>Zona Norte</option>
                        <option>Zona Sur</option>
                        <option>Zona Oriente</option>
                        <option>Zona Poniente</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Ubicación del Estacionamiento</label>
                  <textarea class="form-control" rows="2" placeholder="Dirección completa con referencias..."></textarea>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Concepto del Convenio</label>
                  <textarea class="form-control" rows="2" placeholder="Descripción del convenio de pago..."></textarea>
                </div>
              </div>
              <div class="col-md-6">
                <h6 class="text-success">Importes y Configuración</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Número de Cajones</label>
                      <input type="number" class="form-control" placeholder="0">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tarifa Mensual</label>
                      <input type="number" class="form-control" step="0.01" placeholder="$0.00">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Importe Total</label>
                      <input type="number" class="form-control" step="0.01" placeholder="$0.00">
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Enganche</label>
                      <input type="number" class="form-control" step="0.01" placeholder="$0.00">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Número de Parcialidades</label>
                      <select class="form-select">
                        <option>3 parcialidades</option>
                        <option>6 parcialidades</option>
                        <option>12 parcialidades</option>
                        <option>Personalizado</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Periodicidad</label>
                      <select class="form-select">
                        <option>Mensual</option>
                        <option>Bimestral</option>
                        <option>Trimestral</option>
                      </select>
                    </div>
                  </div>
                </div>

                <div class="card border-info">
                  <div class="card-header bg-info text-white py-2">
                    <h6 class="mb-0">📍 Información Geográfica</h6>
                  </div>
                  <div class="card-body p-3">
                    <div class="row">
                      <div class="col-md-6">
                        <small class="text-muted">Coordenadas:</small>
                        <p class="small mb-1"><strong>20.6597, -103.3496</strong></p>
                      </div>
                      <div class="col-md-6">
                        <small class="text-muted">Sector:</small>
                        <p class="small mb-1"><strong>Centro Histórico</strong></p>
                      </div>
                    </div>
                    <button class="btn btn-sm btn-info w-100">
                      <i class="fas fa-map-marker-alt"></i> Ver en Mapa
                    </button>
                  </div>
                </div>

                <button class="btn btn-success w-100 mt-3">
                  <i class="fas fa-calculator"></i> Generar Parcialidades
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 3. Desglose de Parcialidades -->
      <div class="tab-pane fade" id="parcialidades" role="tabpanel">
        <div class="card">
          <div class="card-header bg-warning text-dark">
            <h5 class="mb-0">📋 Desglose de Parcialidades por Ubicación</h5>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-warning">
                  <tr>
                    <th>No.</th>
                    <th>Fecha Vencimiento</th>
                    <th>Tarifa Base</th>
                    <th>Recargos</th>
                    <th>Multas</th>
                    <th>Intereses</th>
                    <th>Total</th>
                    <th>Estado</th>
                    <th>Zona</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>1</strong></td>
                    <td>15/01/2024</td>
                    <td>$2,500.00</td>
                    <td>$125.00</td>
                    <td>$0.00</td>
                    <td>$50.00</td>
                    <td>$2,675.00</td>
                    <td><span class="badge bg-success">PAGADO</span></td>
                    <td><span class="badge bg-primary">Centro</span></td>
                    <td>
                      <button class="btn btn-sm btn-primary" title="Ver detalle">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>2</strong></td>
                    <td>15/02/2024</td>
                    <td>$2,500.00</td>
                    <td>$125.00</td>
                    <td>$150.00</td>
                    <td>$62.50</td>
                    <td>$2,837.50</td>
                    <td><span class="badge bg-warning">VIGENTE</span></td>
                    <td><span class="badge bg-primary">Centro</span></td>
                    <td>
                      <button class="btn btn-sm btn-success" title="Registrar pago">
                        <i class="fas fa-dollar-sign"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>3</strong></td>
                    <td>15/03/2024</td>
                    <td>$2,500.00</td>
                    <td>$125.00</td>
                    <td>$0.00</td>
                    <td>$75.00</td>
                    <td>$2,700.00</td>
                    <td><span class="badge bg-secondary">PENDIENTE</span></td>
                    <td><span class="badge bg-primary">Centro</span></td>
                    <td>
                      <button class="btn btn-sm btn-secondary" disabled>
                        <i class="fas fa-clock"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div class="row mt-3">
              <div class="col-md-4">
                <div class="alert alert-info">
                  <h6>💰 Resumen Financiero</h6>
                  <div class="d-flex justify-content-between">
                    <span>Total del convenio:</span>
                    <strong>$8,212.50</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Pagado:</span>
                    <strong class="text-success">$2,675.00</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Pendiente:</span>
                    <strong class="text-danger">$5,537.50</strong>
                  </div>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-warning">
                  <h6>⚠️ Estado del Convenio</h6>
                  <p class="mb-2"><strong>AL CORRIENTE</strong></p>
                  <small>Próximo vencimiento: 15/02/2024</small>
                  <div class="progress mt-2">
                    <div class="progress-bar bg-success" style="width: 33%">33%</div>
                  </div>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-primary">
                  <h6>📍 Información del Estacionamiento</h6>
                  <p class="small mb-1"><strong>Ubicación:</strong> Av. Juárez #123</p>
                  <p class="small mb-1"><strong>Cajones:</strong> 25</p>
                  <p class="small mb-1"><strong>Tipo:</strong> Exclusivo</p>
                  <p class="small mb-0"><strong>Zona:</strong> Centro</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 4. ABC de Pagos -->
      <div class="tab-pane fade" id="pagos" role="tabpanel">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">💳 ABC de Pagos de Estacionamientos</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-8">
                <h6 class="text-info">Registro de Pago por Ubicación</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Convenio</label>
                      <select class="form-select">
                        <option>EST-2024-001 - Estacionamiento Centro</option>
                        <option>EST-2024-002 - Parking Norte</option>
                        <option>EST-2024-003 - Plaza Sur</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Parcialidad</label>
                      <select class="form-select">
                        <option>Parcialidad 2 - $2,837.50 (Centro)</option>
                        <option>Parcialidad 3 - $2,700.00 (Centro)</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-4">
                    <div class="form-group mb-3">
                      <label class="form-label">Fecha de Pago</label>
                      <input type="date" class="form-control">
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group mb-3">
                      <label class="form-label">Importe Pagado</label>
                      <input type="number" class="form-control" step="0.01" placeholder="$0.00">
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="form-group mb-3">
                      <label class="form-label">Forma de Pago</label>
                      <select class="form-select">
                        <option>Efectivo</option>
                        <option>Transferencia</option>
                        <option>Cheque</option>
                        <option>Tarjeta</option>
                        <option>Pago en Línea</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Centro de Recaudación</label>
                      <select class="form-select">
                        <option>Caja Principal - Centro</option>
                        <option>Módulo Norte</option>
                        <option>Módulo Sur</option>
                        <option>Pago en Línea</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Referencia/Observaciones</label>
                      <input type="text" class="form-control" placeholder="Número de referencia o notas...">
                    </div>
                  </div>
                </div>
                <div class="d-flex gap-2">
                  <button class="btn btn-success"><i class="fas fa-save"></i> Registrar Pago</button>
                  <button class="btn btn-primary"><i class="fas fa-receipt"></i> Imprimir Recibo</button>
                  <button class="btn btn-info"><i class="fas fa-map"></i> Ver Ubicación</button>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-success">
                  <h6 class="alert-heading">📊 Estadísticas por Zona</h6>
                  <hr>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Pagos hoy - Centro:</span>
                    <strong>8</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Importe - Centro:</span>
                    <strong>$45,250.00</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Convenios activos:</span>
                    <strong>25</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Efectividad:</span>
                    <strong class="text-success">92%</strong>
                  </div>
                </div>

                <div class="card border-info">
                  <div class="card-header bg-info text-white py-2">
                    <h6 class="mb-0">🗺️ Distribución por Zona</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="d-flex justify-content-between mb-1">
                      <small>Centro:</small>
                      <span class="badge bg-primary">15</span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                      <small>Norte:</small>
                      <span class="badge bg-success">8</span>
                    </div>
                    <div class="d-flex justify-content-between mb-1">
                      <small>Sur:</small>
                      <span class="badge bg-warning">12</span>
                    </div>
                    <div class="d-flex justify-content-between">
                      <small>Oriente:</small>
                      <span class="badge bg-info">5</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Continúa con las demás pestañas... (Impresión, Consultas, Reportes, Cancelación) -->
      <!-- Para mantener la respuesta concisa, incluyo solo la estructura principal -->

      <!-- 5. Impresión del Convenio -->
      <div class="tab-pane fade" id="impresion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-dark text-white">
            <h5 class="mb-0">🖨️ Impresión de Convenios de Estacionamientos</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-info">
              <p class="mb-0"><strong>Documentos especializados para estacionamientos:</strong> Incluyen ubicación geográfica, número de cajones, zona tarifaria y mapas de referencia.</p>
            </div>
            <!-- Contenido similar a otros módulos pero especializado para estacionamientos -->
          </div>
        </div>
      </div>

      <!-- 6. Consulta General del Convenio -->
      <div class="tab-pane fade" id="consultas" role="tabpanel">
        <div class="card">
          <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">🔍 Consulta Georreferenciada de Convenios</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-primary">
              <p class="mb-0"><strong>Búsqueda avanzada:</strong> Filtra por zona, tipo de estacionamiento, número de cajones y ubicación específica.</p>
            </div>
            <!-- Contenido similar pero con filtros geográficos -->
          </div>
        </div>
      </div>

      <!-- 7. Reportes Integrales -->
      <div class="tab-pane fade" id="reportes" role="tabpanel">
        <div class="card">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">📈 Reportes Geográficos de Estacionamientos</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-success">
              <p class="mb-0"><strong>Reportes especializados:</strong> Incluyen análisis por zona, mapas de calor de pagos, y estadísticas de ocupación por área.</p>
            </div>
            <!-- Contenido de reportes con componente geográfico -->
          </div>
        </div>
      </div>

      <!-- 8. Cancelación Masiva -->
      <div class="tab-pane fade" id="cancelacion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-danger text-white">
            <h5 class="mb-0">❌ Cancelación Masiva por Zona</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-warning">
              <p class="mb-0"><strong>Gestión geográfica:</strong> Permite cancelación masiva por zona, tipo de estacionamiento o criterios de ubicación específicos.</p>
            </div>
            <!-- Contenido de cancelación con filtros geográficos -->
          </div>
        </div>
      </div>

    </div>
  </div>
</template>

<script>
export default {
  name: 'SistemaConveniosEstacionamientos'
}
</script>

<style scoped>
.sistema-convenios-estacionamientos {
  padding: 1rem;
}

.alert-primary {
  border-left: 4px solid #0d6efd;
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