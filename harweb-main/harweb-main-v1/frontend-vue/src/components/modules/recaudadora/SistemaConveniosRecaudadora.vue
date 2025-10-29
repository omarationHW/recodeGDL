<template>
  <div class="sistema-convenios-recaudadora">
    <!-- 🆕 COMPONENTE DE SISTEMA INTEGRAL DE CONVENIOS -->
    <div class="alert alert-success mb-4">
      <h4 class="alert-heading">🆕 SISTEMA INTEGRAL DE CONVENIOS - Recaudadora</h4>
      <p class="mb-0">Módulo completo de administración de convenios, intereses, parcialidades y pagos</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-handshake me-2 text-success"></i>
              Sistema Integral de Convenios - Recaudadora
            </h2>
            <p class="text-muted mb-0">Gestión completa de convenios de pago para contribuyentes</p>
          </div>
          <div class="badge badge-success">8 MÓDULOS INTEGRADOS</div>
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
            <h5 class="mb-0">📊 ABC del Catálogo de Intereses</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-8">
                <h6 class="text-primary">Gestión de Tasas de Interés</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tipo de Interés</label>
                      <select class="form-select">
                        <option>Moratorio</option>
                        <option>Legal</option>
                        <option>Preferencial</option>
                        <option>Convenio</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Tasa (%)</label>
                      <input type="number" class="form-control" step="0.01" placeholder="Ej: 1.5">
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
                  <h6 class="alert-heading">📋 Configuración Actual</h6>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Tasa Moratorio:</span>
                    <strong>1.5%</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Tasa Legal:</span>
                    <strong>1.0%</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Vigencia:</span>
                    <strong>01/01/2024</strong>
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
            <h5 class="mb-0">📄 ABC del Convenio</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-success">Datos Generales del Convenio</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Contribuyente</label>
                  <div class="input-group">
                    <input type="text" class="form-control" placeholder="Buscar contribuyente...">
                    <button class="btn btn-outline-secondary" type="button">
                      <i class="fas fa-search"></i>
                    </button>
                  </div>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Número de Convenio</label>
                      <input type="text" class="form-control" placeholder="Auto-generado" readonly>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Fecha de Convenio</label>
                      <input type="date" class="form-control">
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Concepto</label>
                  <textarea class="form-control" rows="3" placeholder="Descripción del convenio..."></textarea>
                </div>
              </div>
              <div class="col-md-6">
                <h6 class="text-success">Importes y Parcialidades</h6>
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
                <button class="btn btn-success w-100">
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
            <h5 class="mb-0">📋 Desglose de Parcialidades</h5>
          </div>
          <div class="card-body">
            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-warning">
                  <tr>
                    <th>No.</th>
                    <th>Fecha Vencimiento</th>
                    <th>Capital</th>
                    <th>Intereses</th>
                    <th>Total</th>
                    <th>Estado</th>
                    <th>Rubros</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>1</strong></td>
                    <td>15/01/2024</td>
                    <td>$5,000.00</td>
                    <td>$250.00</td>
                    <td>$5,250.00</td>
                    <td><span class="badge bg-success">PAGADO</span></td>
                    <td>
                      <small>Predial, Multas, Recargos</small>
                    </td>
                    <td>
                      <button class="btn btn-sm btn-primary" title="Ver detalle">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>2</strong></td>
                    <td>15/02/2024</td>
                    <td>$5,000.00</td>
                    <td>$275.00</td>
                    <td>$5,275.00</td>
                    <td><span class="badge bg-warning">VIGENTE</span></td>
                    <td>
                      <small>Predial, Multas, Recargos</small>
                    </td>
                    <td>
                      <button class="btn btn-sm btn-success" title="Registrar pago">
                        <i class="fas fa-dollar-sign"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>3</strong></td>
                    <td>15/03/2024</td>
                    <td>$5,000.00</td>
                    <td>$300.00</td>
                    <td>$5,300.00</td>
                    <td><span class="badge bg-secondary">PENDIENTE</span></td>
                    <td>
                      <small>Predial, Multas, Recargos</small>
                    </td>
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
              <div class="col-md-6">
                <div class="alert alert-info">
                  <h6>💰 Resumen Financiero</h6>
                  <div class="d-flex justify-content-between">
                    <span>Total del convenio:</span>
                    <strong>$15,825.00</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Pagado:</span>
                    <strong class="text-success">$5,250.00</strong>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Pendiente:</span>
                    <strong class="text-danger">$10,575.00</strong>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="alert alert-warning">
                  <h6>⚠️ Estado del Convenio</h6>
                  <p class="mb-2"><strong>AL CORRIENTE</strong></p>
                  <small>Próximo vencimiento: 15/02/2024</small>
                  <div class="progress mt-2">
                    <div class="progress-bar bg-success" style="width: 33%">33%</div>
                  </div>
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
            <h5 class="mb-0">💳 ABC de Pagos</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-8">
                <h6 class="text-info">Registro de Pago</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Convenio</label>
                      <select class="form-select">
                        <option>CONV-2024-001 - Juan Pérez</option>
                        <option>CONV-2024-002 - María García</option>
                        <option>CONV-2024-003 - Carlos López</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Parcialidad</label>
                      <select class="form-select">
                        <option>Parcialidad 2 - $5,275.00</option>
                        <option>Parcialidad 3 - $5,300.00</option>
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
                      </select>
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Referencia/Observaciones</label>
                  <input type="text" class="form-control" placeholder="Número de referencia o notas...">
                </div>
                <div class="d-flex gap-2">
                  <button class="btn btn-success"><i class="fas fa-save"></i> Registrar Pago</button>
                  <button class="btn btn-primary"><i class="fas fa-receipt"></i> Imprimir Recibo</button>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-success">
                  <h6 class="alert-heading">📊 Estadísticas de Pagos</h6>
                  <hr>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Pagos del día:</span>
                    <strong>15</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Importe del día:</span>
                    <strong>$125,450.00</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Convenios liquidados:</span>
                    <strong>3</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Efectividad:</span>
                    <strong class="text-success">85%</strong>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 5. Impresión del Convenio -->
      <div class="tab-pane fade" id="impresion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-dark text-white">
            <h5 class="mb-0">🖨️ Impresión del Convenio</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-dark">Documentos Oficiales</h6>
                <div class="list-group">
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="mb-1">📄 Oficio del Convenio</h6>
                      <small class="text-muted">Documento oficial del acuerdo de pago</small>
                    </div>
                    <button class="btn btn-primary btn-sm">
                      <i class="fas fa-print"></i> Imprimir
                    </button>
                  </div>
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="mb-1">📝 Pagaré</h6>
                      <small class="text-muted">Documento de garantía del convenio</small>
                    </div>
                    <button class="btn btn-primary btn-sm">
                      <i class="fas fa-print"></i> Imprimir
                    </button>
                  </div>
                  <div class="list-group-item d-flex justify-content-between align-items-center">
                    <div>
                      <h6 class="mb-1">📋 Tabla de Parcialidades</h6>
                      <small class="text-muted">Calendario de pagos detallado</small>
                    </div>
                    <button class="btn btn-primary btn-sm">
                      <i class="fas fa-print"></i> Imprimir
                    </button>
                  </div>
                </div>
                <div class="mt-3">
                  <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="includeLegal">
                    <label class="form-check-label" for="includeLegal">
                      Incluir fundamentos legales
                    </label>
                  </div>
                  <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="includeSeal">
                    <label class="form-check-label" for="includeSeal">
                      Incluir sello oficial
                    </label>
                  </div>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card border-secondary">
                  <div class="card-header bg-secondary text-white">
                    <h6 class="mb-0">📄 Vista Previa - Oficio del Convenio</h6>
                  </div>
                  <div class="card-body bg-light" style="min-height: 300px;">
                    <div class="text-center mb-3">
                      <h6>MUNICIPIO DE GUADALAJARA</h6>
                      <small>DIRECCIÓN DE INGRESOS</small>
                    </div>
                    <hr>
                    <p><strong>CONVENIO DE PAGO No. CONV-2024-001</strong></p>
                    <p><strong>CONTRIBUYENTE:</strong> Juan Pérez García</p>
                    <p><strong>FECHA:</strong> 15 de Enero de 2024</p>
                    <p><strong>CONCEPTO:</strong> Pago de impuesto predial y accesorios</p>
                    <hr>
                    <p><strong>IMPORTE TOTAL:</strong> $15,825.00</p>
                    <p><strong>PARCIALIDADES:</strong> 3 pagos mensuales</p>
                    <div class="text-center mt-4">
                      <small class="text-muted">Este es solo un ejemplo de vista previa</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 6. Consulta General del Convenio -->
      <div class="tab-pane fade" id="consultas" role="tabpanel">
        <div class="card">
          <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">🔍 Consulta General del Convenio</h5>
          </div>
          <div class="card-body">
            <div class="row mb-4">
              <div class="col-md-8">
                <div class="input-group">
                  <input type="text" class="form-control" placeholder="Buscar por número de convenio, contribuyente, RFC...">
                  <button class="btn btn-primary" type="button">
                    <i class="fas fa-search"></i> Buscar
                  </button>
                </div>
              </div>
              <div class="col-md-4">
                <select class="form-select">
                  <option>Todos los estados</option>
                  <option>Vigentes</option>
                  <option>Vencidos</option>
                  <option>Liquidados</option>
                  <option>Cancelados</option>
                </select>
              </div>
            </div>

            <div class="row">
              <div class="col-md-8">
                <div class="table-responsive">
                  <table class="table table-hover">
                    <thead class="table-secondary">
                      <tr>
                        <th>Convenio</th>
                        <th>Contribuyente</th>
                        <th>Fecha</th>
                        <th>Total</th>
                        <th>Pagado</th>
                        <th>Pendiente</th>
                        <th>Estado</th>
                        <th>Acciones</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td><strong>CONV-2024-001</strong></td>
                        <td>Juan Pérez García</td>
                        <td>15/01/2024</td>
                        <td>$15,825.00</td>
                        <td class="text-success">$5,250.00</td>
                        <td class="text-danger">$10,575.00</td>
                        <td><span class="badge bg-success">VIGENTE</span></td>
                        <td>
                          <button class="btn btn-sm btn-primary" title="Ver detalle">
                            <i class="fas fa-eye"></i>
                          </button>
                        </td>
                      </tr>
                      <tr>
                        <td><strong>CONV-2024-002</strong></td>
                        <td>María García López</td>
                        <td>10/01/2024</td>
                        <td>$25,000.00</td>
                        <td class="text-success">$25,000.00</td>
                        <td class="text-success">$0.00</td>
                        <td><span class="badge bg-primary">LIQUIDADO</span></td>
                        <td>
                          <button class="btn btn-sm btn-success" title="Ver detalle">
                            <i class="fas fa-check"></i>
                          </button>
                        </td>
                      </tr>
                      <tr>
                        <td><strong>CONV-2024-003</strong></td>
                        <td>Carlos López Ruiz</td>
                        <td>05/01/2024</td>
                        <td>$18,500.00</td>
                        <td class="text-warning">$6,000.00</td>
                        <td class="text-danger">$12,500.00</td>
                        <td><span class="badge bg-warning">VENCIDO</span></td>
                        <td>
                          <button class="btn btn-sm btn-warning" title="Gestionar">
                            <i class="fas fa-exclamation-triangle"></i>
                          </button>
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-primary">
                  <h6>📊 Resumen de Consulta</h6>
                  <hr>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Total convenios:</span>
                    <strong>3</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Vigentes:</span>
                    <strong class="text-success">1</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Liquidados:</span>
                    <strong class="text-primary">1</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Vencidos:</span>
                    <strong class="text-warning">1</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Importe total:</span>
                    <strong>$59,325.00</strong>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 7. Reportes Integrales -->
      <div class="tab-pane fade" id="reportes" role="tabpanel">
        <div class="card">
          <div class="card-header bg-success text-white">
            <h5 class="mb-0">📈 Reportes Integrales</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-4">
                <h6 class="text-success">Padrón de Convenios</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Convenios Vigentes
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Convenios Liquidados
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Convenios Vencidos
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Padrón Completo
                  </button>
                </div>
              </div>
              <div class="col-md-4">
                <h6 class="text-warning">Reportes de Adeudos</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Adeudos por Vencer
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Adeudos Vencidos
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Análisis de Cartera
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Proyección de Ingresos
                  </button>
                </div>
              </div>
              <div class="col-md-4">
                <h6 class="text-info">Reportes de Pagos</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Ingresos Diarios
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Ingresos Mensuales
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Formas de Pago
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Efectividad de Cobro
                  </button>
                </div>
              </div>
            </div>

            <!-- Filtros para reportes -->
            <div class="card bg-light">
              <div class="card-body">
                <h6>🔧 Filtros para Reportes</h6>
                <div class="row">
                  <div class="col-md-3">
                    <div class="form-group mb-3">
                      <label class="form-label small">Fecha Desde</label>
                      <input type="date" class="form-control form-control-sm">
                    </div>
                  </div>
                  <div class="col-md-3">
                    <div class="form-group mb-3">
                      <label class="form-label small">Fecha Hasta</label>
                      <input type="date" class="form-control form-control-sm">
                    </div>
                  </div>
                  <div class="col-md-3">
                    <div class="form-group mb-3">
                      <label class="form-label small">Estado</label>
                      <select class="form-select form-select-sm">
                        <option>Todos</option>
                        <option>Vigentes</option>
                        <option>Vencidos</option>
                        <option>Liquidados</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-3">
                    <div class="form-group mb-3">
                      <label class="form-label small">Formato</label>
                      <select class="form-select form-select-sm">
                        <option>Excel (.xlsx)</option>
                        <option>PDF</option>
                        <option>CSV</option>
                      </select>
                    </div>
                  </div>
                </div>
                <button class="btn btn-success btn-sm">
                  <i class="fas fa-download"></i> Generar Reporte
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 8. Cancelación Masiva -->
      <div class="tab-pane fade" id="cancelacion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-danger text-white">
            <h5 class="mb-0">❌ Cancelación Masiva de Convenios</h5>
          </div>
          <div class="card-body">
            <div class="alert alert-warning">
              <h6 class="alert-heading">⚠️ Proceso de Cancelación Masiva</h6>
              <p>Esta herramienta permite cancelar múltiples convenios que cumplan con criterios específicos de incumplimiento.</p>
            </div>

            <div class="row">
              <div class="col-md-6">
                <h6 class="text-danger">Criterios de Cancelación</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Parcialidades vencidas mínimas</label>
                  <select class="form-select">
                    <option>2 o más parcialidades vencidas</option>
                    <option>3 o más parcialidades vencidas</option>
                    <option>4 o más parcialidades vencidas</option>
                    <option>Todas las parcialidades vencidas</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Días de vencimiento</label>
                  <select class="form-select">
                    <option>30 días o más</option>
                    <option>60 días o más</option>
                    <option>90 días o más</option>
                    <option>180 días o más</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Periodo de convenios</label>
                  <div class="row">
                    <div class="col-md-6">
                      <input type="date" class="form-control" placeholder="Desde">
                    </div>
                    <div class="col-md-6">
                      <input type="date" class="form-control" placeholder="Hasta">
                    </div>
                  </div>
                </div>
                <button class="btn btn-warning w-100">
                  <i class="fas fa-search"></i> Buscar Convenios para Cancelar
                </button>
              </div>
              <div class="col-md-6">
                <h6 class="text-info">Resultados de Búsqueda</h6>
                <div class="alert alert-info">
                  <p><strong>Convenios encontrados:</strong> 15</p>
                  <p><strong>Importe total afectado:</strong> $485,250.00</p>
                  <p><strong>Promedio de días vencidos:</strong> 65 días</p>
                </div>

                <div class="table-responsive" style="max-height: 200px;">
                  <table class="table table-sm">
                    <thead class="table-danger">
                      <tr>
                        <th>
                          <input type="checkbox" class="form-check-input">
                        </th>
                        <th>Convenio</th>
                        <th>Contribuyente</th>
                        <th>Vencidas</th>
                        <th>Días</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr>
                        <td><input type="checkbox" class="form-check-input"></td>
                        <td>CONV-2024-003</td>
                        <td>Carlos López</td>
                        <td>2</td>
                        <td>65</td>
                      </tr>
                      <tr>
                        <td><input type="checkbox" class="form-check-input"></td>
                        <td>CONV-2024-007</td>
                        <td>Ana Martínez</td>
                        <td>3</td>
                        <td>45</td>
                      </tr>
                      <tr>
                        <td><input type="checkbox" class="form-check-input"></td>
                        <td>CONV-2024-012</td>
                        <td>Pedro Sánchez</td>
                        <td>2</td>
                        <td>78</td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div class="mt-3 d-grid gap-2">
                  <button class="btn btn-danger" disabled>
                    <i class="fas fa-times-circle"></i> Cancelar Convenios Seleccionados
                  </button>
                  <small class="text-muted text-center">
                    Seleccione al menos un convenio para habilitar la cancelación
                  </small>
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
  name: 'SistemaConveniosRecaudadora'
}
</script>

<style scoped>
.sistema-convenios-recaudadora {
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