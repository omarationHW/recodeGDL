<template>
  <div class="sistema-apremios-recaudadora">
    <!-- 🆕 COMPONENTE DE SISTEMA INTEGRAL DE APREMIOS -->
    <div class="alert alert-warning mb-4">
      <h4 class="alert-heading">🆕 SISTEMA INTEGRAL DE APREMIOS - Recaudadora</h4>
      <p class="mb-0">Módulo completo de administración de apremios, ejecutores, folios y notificaciones</p>
    </div>

    <!-- Header -->
    <div class="row mb-4">
      <div class="col-12">
        <div class="d-flex justify-content-between align-items-center">
          <div>
            <h2 class="h4 mb-1">
              <i class="fas fa-gavel me-2 text-warning"></i>
              Sistema Integral de Apremios - Recaudadora
            </h2>
            <p class="text-muted mb-0">Gestión completa de procedimientos de apremio y cobro coactivo</p>
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
            <h5 class="mb-0">👮 ABC del Catálogo de Ejecutores</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-8">
                <h6 class="text-primary">Gestión de Personal Ejecutor</h6>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Clave del Ejecutor</label>
                      <input type="text" class="form-control" placeholder="Ej: EJE-001">
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
                      <label class="form-label">Zona/Territorio Asignado</label>
                      <select class="form-select">
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
                      <label class="form-label">Estado</label>
                      <select class="form-select">
                        <option>Activo</option>
                        <option>Inactivo</option>
                        <option>Suspendido</option>
                        <option>Vacaciones</option>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Observaciones</label>
                  <textarea class="form-control" rows="2" placeholder="Notas adicionales..."></textarea>
                </div>
                <div class="d-flex gap-2">
                  <button class="btn btn-success"><i class="fas fa-plus"></i> Alta</button>
                  <button class="btn btn-warning"><i class="fas fa-edit"></i> Modificar</button>
                  <button class="btn btn-danger"><i class="fas fa-trash"></i> Baja</button>
                </div>
              </div>
              <div class="col-md-4">
                <div class="alert alert-info">
                  <h6 class="alert-heading">📊 Estadísticas de Ejecutores</h6>
                  <hr>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Total activos:</span>
                    <strong>15</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Con carga asignada:</span>
                    <strong>12</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Disponibles:</span>
                    <strong>3</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Efectividad promedio:</span>
                    <strong class="text-success">75%</strong>
                  </div>
                </div>

                <div class="card border-primary">
                  <div class="card-header bg-primary text-white py-2">
                    <h6 class="mb-0">Top Ejecutores</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="d-flex justify-content-between align-items-center mb-1">
                      <small><strong>EJE-001</strong> - Juan Pérez</small>
                      <span class="badge bg-success">95%</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center mb-1">
                      <small><strong>EJE-003</strong> - María García</small>
                      <span class="badge bg-success">88%</span>
                    </div>
                    <div class="d-flex justify-content-between align-items-center">
                      <small><strong>EJE-007</strong> - Carlos López</small>
                      <span class="badge bg-warning">82%</span>
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
            <h5 class="mb-0">📄 Generación de Folios de Notificación/Requerimiento</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-success">Criterios de Generación</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Tipo de Folio</label>
                  <select class="form-select">
                    <option>Notificación de Adeudo</option>
                    <option>Requerimiento de Pago</option>
                    <option>Citatorio de Embargo</option>
                    <option>Notificación de Embargo</option>
                  </select>
                </div>
                <div class="row">
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Rango de Cuentas</label>
                      <div class="input-group">
                        <input type="text" class="form-control" placeholder="Desde">
                        <span class="input-group-text">-</span>
                        <input type="text" class="form-control" placeholder="Hasta">
                      </div>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Monto Mínimo</label>
                      <input type="number" class="form-control" step="0.01" placeholder="$0.00">
                    </div>
                  </div>
                </div>
                <div class="row">
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
                  <div class="col-md-6">
                    <div class="form-group mb-3">
                      <label class="form-label">Zona</label>
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
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Tipo de Contribuyente</label>
                  <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="personaFisica" checked>
                    <label class="form-check-label" for="personaFisica">
                      Persona Física
                    </label>
                  </div>
                  <div class="form-check">
                    <input class="form-check-input" type="checkbox" id="personaMoral" checked>
                    <label class="form-check-label" for="personaMoral">
                      Persona Moral
                    </label>
                  </div>
                </div>
                <button class="btn btn-success w-100">
                  <i class="fas fa-cogs"></i> Generar Folios
                </button>
              </div>
              <div class="col-md-6">
                <h6 class="text-success">Vista Previa de Generación</h6>
                <div class="alert alert-success">
                  <h6>📋 Resultados de Búsqueda</h6>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Cuentas encontradas:</span>
                    <strong>1,250</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Adeudo promedio:</span>
                    <strong>$15,850.00</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Adeudo total:</span>
                    <strong>$19,812,500.00</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Folios a generar:</span>
                    <strong>1,250</strong>
                  </div>
                </div>

                <div class="card border-info">
                  <div class="card-header bg-info text-white py-2">
                    <h6 class="mb-0">Configuración del Folio</h6>
                  </div>
                  <div class="card-body">
                    <div class="form-group mb-3">
                      <label class="form-label small">Serie del Folio</label>
                      <input type="text" class="form-control form-control-sm" value="NOT-2024-" readonly>
                    </div>
                    <div class="form-group mb-3">
                      <label class="form-label small">Folio Inicial</label>
                      <input type="number" class="form-control form-control-sm" value="1001">
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
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 3. Impresión de Folios -->
      <div class="tab-pane fade" id="impresion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-dark text-white">
            <h5 class="mb-0">🖨️ Impresión de Folios con Fundamentos Legales</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-dark">Selección de Folios para Impresión</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Rango de Folios</label>
                  <div class="input-group">
                    <input type="text" class="form-control" placeholder="NOT-2024-1001">
                    <span class="input-group-text">a</span>
                    <input type="text" class="form-control" placeholder="NOT-2024-1250">
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Ejecutor Asignado</label>
                  <select class="form-select">
                    <option>Todos los ejecutores</option>
                    <option>EJE-001 - Juan Pérez</option>
                    <option>EJE-003 - María García</option>
                    <option>EJE-007 - Carlos López</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Estado del Folio</label>
                  <select class="form-select">
                    <option>Generado (Pendiente de Impresión)</option>
                    <option>Impreso</option>
                    <option>Notificado</option>
                    <option>Todos los estados</option>
                  </select>
                </div>

                <h6 class="text-dark mt-4">Configuración de Impresión</h6>
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="incluirFundamentos" checked>
                  <label class="form-check-label" for="incluirFundamentos">
                    Incluir fundamentos legales
                  </label>
                </div>
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="formatoDirPolitica" checked>
                  <label class="form-check-label" for="formatoDirPolitica">
                    Formato Dirección de Política Fiscal
                  </label>
                </div>
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="formatoMejora" checked>
                  <label class="form-check-label" for="formatoMejora">
                    Formato Mejora Hacendaria
                  </label>
                </div>
                <div class="form-check">
                  <input class="form-check-input" type="checkbox" id="incluirSello">
                  <label class="form-check-label" for="incluirSello">
                    Incluir sello oficial
                  </label>
                </div>

                <div class="d-grid gap-2 mt-4">
                  <button class="btn btn-primary">
                    <i class="fas fa-print"></i> Imprimir Folios Seleccionados
                  </button>
                  <button class="btn btn-secondary">
                    <i class="fas fa-file-pdf"></i> Generar PDF
                  </button>
                </div>
              </div>
              <div class="col-md-6">
                <div class="card border-secondary">
                  <div class="card-header bg-secondary text-white">
                    <h6 class="mb-0">📄 Vista Previa - Folio de Notificación</h6>
                  </div>
                  <div class="card-body bg-light" style="min-height: 400px; font-size: 11px;">
                    <div class="text-center mb-2">
                      <h6 style="font-size: 12px;">MUNICIPIO DE GUADALAJARA</h6>
                      <small style="font-size: 10px;">DIRECCIÓN DE POLÍTICA FISCAL Y MEJORA HACENDARIA</small>
                    </div>
                    <hr>
                    <p><strong>FOLIO: NOT-2024-1001</strong></p>
                    <p><strong>NOTIFICACIÓN DE ADEUDO</strong></p>
                    <hr>
                    <p><strong>CONTRIBUYENTE:</strong> Juan Pérez García</p>
                    <p><strong>CUENTA PREDIAL:</strong> 123456789</p>
                    <p><strong>DOMICILIO:</strong> Av. Principal #123, Col. Centro</p>
                    <hr>
                    <p><strong>ADEUDO TOTAL:</strong> $15,850.00</p>
                    <p><strong>CONCEPTOS:</strong></p>
                    <ul style="font-size: 10px; margin-left: 15px;">
                      <li>Impuesto Predial 2023: $8,500.00</li>
                      <li>Recargos: $2,550.00</li>
                      <li>Multas: $4,800.00</li>
                    </ul>
                    <hr>
                    <p style="font-size: 10px;"><strong>FUNDAMENTO LEGAL:</strong></p>
                    <p style="font-size: 9px;">Con fundamento en los artículos 31 fracción IV de la Constitución Política de los Estados Unidos Mexicanos, 115 fracción IV de la misma Constitución...</p>
                    <hr>
                    <p style="font-size: 10px;"><strong>PLAZO:</strong> 15 días hábiles para el pago</p>
                    <p style="font-size: 10px;"><strong>EJECUTOR:</strong> Juan Pérez - EJE-001</p>
                    <div class="text-center mt-3">
                      <small class="text-muted">Vista previa simplificada</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 4. Modificación de Folios -->
      <div class="tab-pane fade" id="modificacion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-warning text-dark">
            <h5 class="mb-0">✏️ Modificación de Datos del Folio</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-6">
                <h6 class="text-warning">Búsqueda del Folio a Modificar</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Número de Folio</label>
                  <div class="input-group">
                    <input type="text" class="form-control" placeholder="NOT-2024-1001">
                    <button class="btn btn-outline-secondary" type="button">
                      <i class="fas fa-search"></i>
                    </button>
                  </div>
                </div>

                <div class="alert alert-info">
                  <h6>📋 Folio Encontrado</h6>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Folio:</span>
                    <strong>NOT-2024-1001</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Contribuyente:</span>
                    <strong>Juan Pérez García</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-1">
                    <span>Estado:</span>
                    <span class="badge bg-warning">GENERADO</span>
                  </div>
                  <div class="d-flex justify-content-between">
                    <span>Ejecutor:</span>
                    <strong>EJE-001</strong>
                  </div>
                </div>

                <h6 class="text-warning">Datos Modificables</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Ejecutor Asignado</label>
                  <select class="form-select">
                    <option>EJE-001 - Juan Pérez</option>
                    <option>EJE-003 - María García</option>
                    <option>EJE-007 - Carlos López</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Fecha de Notificación</label>
                  <input type="date" class="form-control">
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Días para Respuesta</label>
                  <select class="form-select">
                    <option>15 días</option>
                    <option>30 días</option>
                    <option>45 días</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Estado del Folio</label>
                  <select class="form-select">
                    <option>Generado</option>
                    <option>Impreso</option>
                    <option>Asignado</option>
                    <option>Notificado</option>
                    <option>Practicado</option>
                    <option>Cancelado</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Observaciones de Modificación</label>
                  <textarea class="form-control" rows="3" placeholder="Motivo de la modificación..."></textarea>
                </div>
                <button class="btn btn-warning w-100">
                  <i class="fas fa-save"></i> Guardar Modificaciones
                </button>
              </div>
              <div class="col-md-6">
                <h6 class="text-info">Historial de Modificaciones</h6>
                <div class="timeline" style="max-height: 400px; overflow-y: auto;">
                  <div class="card mb-2">
                    <div class="card-body p-2">
                      <div class="d-flex justify-content-between">
                        <small><strong>Creación</strong></small>
                        <small class="text-muted">15/01/2024 10:30</small>
                      </div>
                      <small class="text-muted">
                        Folio generado automáticamente<br>
                        Asignado a: EJE-001 - Juan Pérez
                      </small>
                    </div>
                  </div>
                  <div class="card mb-2">
                    <div class="card-body p-2">
                      <div class="d-flex justify-content-between">
                        <small><strong>Reasignación</strong></small>
                        <small class="text-muted">16/01/2024 14:15</small>
                      </div>
                      <small class="text-muted">
                        Reasignado de EJE-001 a EJE-003<br>
                        Motivo: Redistribución de carga
                      </small>
                    </div>
                  </div>
                  <div class="card mb-2">
                    <div class="card-body p-2">
                      <div class="d-flex justify-content-between">
                        <small><strong>Modificación</strong></small>
                        <small class="text-muted">17/01/2024 09:45</small>
                      </div>
                      <small class="text-muted">
                        Cambio de fecha de notificación<br>
                        De: 20/01/2024 a: 25/01/2024
                      </small>
                    </div>
                  </div>
                </div>

                <div class="alert alert-warning mt-3">
                  <h6>⚠️ Consideraciones Importantes</h6>
                  <ul class="mb-0" style="font-size: 13px;">
                    <li>Las modificaciones quedan registradas en el historial</li>
                    <li>Solo se pueden modificar folios en estado "Generado" o "Asignado"</li>
                    <li>La reasignación de ejecutor requiere autorización</li>
                    <li>Los cambios de fecha afectan los plazos legales</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 5. Consulta de Folios -->
      <div class="tab-pane fade" id="consulta" role="tabpanel">
        <div class="card">
          <div class="card-header bg-info text-white">
            <h5 class="mb-0">🔍 Consulta de Folios</h5>
          </div>
          <div class="card-body">
            <div class="row mb-4">
              <div class="col-md-3">
                <div class="form-group">
                  <label class="form-label">Número de Folio</label>
                  <input type="text" class="form-control" placeholder="NOT-2024-1001">
                </div>
              </div>
              <div class="col-md-3">
                <div class="form-group">
                  <label class="form-label">Contribuyente</label>
                  <input type="text" class="form-control" placeholder="Nombre o RFC">
                </div>
              </div>
              <div class="col-md-2">
                <div class="form-group">
                  <label class="form-label">Ejecutor</label>
                  <select class="form-select">
                    <option>Todos</option>
                    <option>EJE-001</option>
                    <option>EJE-003</option>
                    <option>EJE-007</option>
                  </select>
                </div>
              </div>
              <div class="col-md-2">
                <div class="form-group">
                  <label class="form-label">Estado</label>
                  <select class="form-select">
                    <option>Todos</option>
                    <option>Generado</option>
                    <option>Asignado</option>
                    <option>Notificado</option>
                    <option>Practicado</option>
                  </select>
                </div>
              </div>
              <div class="col-md-2">
                <div class="form-group">
                  <label class="form-label">&nbsp;</label>
                  <button class="btn btn-info w-100">
                    <i class="fas fa-search"></i> Buscar
                  </button>
                </div>
              </div>
            </div>

            <div class="table-responsive">
              <table class="table table-striped table-hover">
                <thead class="table-info">
                  <tr>
                    <th>Folio</th>
                    <th>Tipo</th>
                    <th>Contribuyente</th>
                    <th>Cuenta</th>
                    <th>Adeudo</th>
                    <th>Ejecutor</th>
                    <th>Estado</th>
                    <th>Fecha Generación</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>NOT-2024-1001</strong></td>
                    <td>Notificación</td>
                    <td>Juan Pérez García</td>
                    <td>123456789</td>
                    <td>$15,850.00</td>
                    <td>EJE-003</td>
                    <td><span class="badge bg-warning">ASIGNADO</span></td>
                    <td>15/01/2024</td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button class="btn btn-primary" title="Ver detalle">
                          <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-warning" title="Modificar">
                          <i class="fas fa-edit"></i>
                        </button>
                        <button class="btn btn-secondary" title="Imprimir">
                          <i class="fas fa-print"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>REQ-2024-0001</strong></td>
                    <td>Requerimiento</td>
                    <td>María García López</td>
                    <td>987654321</td>
                    <td>$22,300.00</td>
                    <td>EJE-001</td>
                    <td><span class="badge bg-success">NOTIFICADO</span></td>
                    <td>12/01/2024</td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button class="btn btn-primary" title="Ver detalle">
                          <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-success" title="Marcar como practicado">
                          <i class="fas fa-check"></i>
                        </button>
                        <button class="btn btn-secondary" title="Imprimir">
                          <i class="fas fa-print"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>EMB-2024-0001</strong></td>
                    <td>Embargo</td>
                    <td>Carlos López Ruiz</td>
                    <td>456789123</td>
                    <td>$45,120.00</td>
                    <td>EJE-007</td>
                    <td><span class="badge bg-primary">PRACTICADO</span></td>
                    <td>08/01/2024</td>
                    <td>
                      <div class="btn-group btn-group-sm">
                        <button class="btn btn-primary" title="Ver detalle">
                          <i class="fas fa-eye"></i>
                        </button>
                        <button class="btn btn-info" title="Ver acta">
                          <i class="fas fa-file-alt"></i>
                        </button>
                        <button class="btn btn-secondary" title="Imprimir">
                          <i class="fas fa-print"></i>
                        </button>
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="row mt-3">
              <div class="col-md-8">
                <nav>
                  <ul class="pagination pagination-sm">
                    <li class="page-item disabled">
                      <span class="page-link">Anterior</span>
                    </li>
                    <li class="page-item active">
                      <span class="page-link">1</span>
                    </li>
                    <li class="page-item">
                      <a class="page-link" href="#">2</a>
                    </li>
                    <li class="page-item">
                      <a class="page-link" href="#">3</a>
                    </li>
                    <li class="page-item">
                      <a class="page-link" href="#">Siguiente</a>
                    </li>
                  </ul>
                </nav>
              </div>
              <div class="col-md-4">
                <div class="alert alert-info py-2">
                  <small>
                    Mostrando 1-3 de 1,250 folios encontrados
                  </small>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 6. Gestión Masiva -->
      <div class="tab-pane fade" id="gestion" role="tabpanel">
        <div class="card">
          <div class="card-header bg-secondary text-white">
            <h5 class="mb-0">⚙️ Gestión Masiva de Folios</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-4">
                <h6 class="text-secondary">Asignación Masiva</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Rango de Folios</label>
                  <div class="input-group">
                    <input type="text" class="form-control" placeholder="Desde">
                    <span class="input-group-text">-</span>
                    <input type="text" class="form-control" placeholder="Hasta">
                  </div>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Asignar a Ejecutor</label>
                  <select class="form-select">
                    <option>EJE-001 - Juan Pérez</option>
                    <option>EJE-003 - María García</option>
                    <option>EJE-007 - Carlos López</option>
                  </select>
                </div>
                <button class="btn btn-secondary w-100 mb-3">
                  <i class="fas fa-user-plus"></i> Asignar Masivamente
                </button>

                <h6 class="text-danger">Cancelación Masiva</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Criterio de Cancelación</label>
                  <select class="form-select">
                    <option>Folios sin asignar (>30 días)</option>
                    <option>Folios duplicados</option>
                    <option>Cuentas inexistentes</option>
                    <option>Adeudos ya pagados</option>
                  </select>
                </div>
                <button class="btn btn-danger w-100">
                  <i class="fas fa-times-circle"></i> Cancelar Masivamente
                </button>
              </div>
              <div class="col-md-4">
                <h6 class="text-success">Practicar Folios Masivamente</h6>
                <div class="form-group mb-3">
                  <label class="form-label">Ejecutor</label>
                  <select class="form-select">
                    <option>EJE-001 - Juan Pérez</option>
                    <option>EJE-003 - María García</option>
                    <option>EJE-007 - Carlos López</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Fecha de Práctica</label>
                  <input type="date" class="form-control">
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Tipo de Resultado</label>
                  <select class="form-select">
                    <option>Notificado Personalmente</option>
                    <option>Notificado por Instructivo</option>
                    <option>Domicilio No Localizado</option>
                    <option>Se Negó a Recibir</option>
                    <option>No Había Persona Capacitada</option>
                  </select>
                </div>
                <div class="form-group mb-3">
                  <label class="form-label">Observaciones Generales</label>
                  <textarea class="form-control" rows="2" placeholder="Observaciones aplicables a todos los folios..."></textarea>
                </div>
                <button class="btn btn-success w-100">
                  <i class="fas fa-check-double"></i> Practicar Folios
                </button>
              </div>
              <div class="col-md-4">
                <div class="alert alert-primary">
                  <h6>📊 Estadísticas de Gestión</h6>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Folios pendientes:</span>
                    <strong>1,250</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Sin asignar:</span>
                    <strong class="text-warning">125</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Asignados:</span>
                    <strong class="text-info">890</strong>
                  </div>
                  <div class="d-flex justify-content-between mb-2">
                    <span>Notificados:</span>
                    <strong class="text-success">235</strong>
                  </div>
                  <hr>
                  <div class="d-flex justify-content-between">
                    <span>Efectividad:</span>
                    <strong class="text-success">75%</strong>
                  </div>
                </div>

                <div class="card border-warning">
                  <div class="card-header bg-warning text-dark py-2">
                    <h6 class="mb-0">⚠️ Alertas del Sistema</h6>
                  </div>
                  <div class="card-body p-2">
                    <div class="alert alert-warning py-1 mb-2">
                      <small><strong>125 folios</strong> sin asignar por más de 30 días</small>
                    </div>
                    <div class="alert alert-info py-1 mb-2">
                      <small><strong>15 folios</strong> con cuentas duplicadas</small>
                    </div>
                    <div class="alert alert-success py-1 mb-0">
                      <small><strong>45 adeudos</strong> pagados posterior a la generación</small>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- 7. Reportes de Apremios -->
      <div class="tab-pane fade" id="reportes" role="tabpanel">
        <div class="card">
          <div class="card-header bg-primary text-white">
            <h5 class="mb-0">📊 Reportes de Apremios</h5>
          </div>
          <div class="card-body">
            <div class="row">
              <div class="col-md-3">
                <h6 class="text-primary">Catálogo de Ejecutores</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Ejecutores Activos
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Carga de Trabajo por Ejecutor
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Efectividad por Ejecutor
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Historial de Asignaciones
                  </button>
                </div>
              </div>
              <div class="col-md-3">
                <h6 class="text-warning">Listado de Descuentos</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Descuentos Aplicados
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Descuentos por Ejecutor
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Análisis de Descuentos
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-warning me-2"></i>
                    Impacto Financiero
                  </button>
                </div>
              </div>
              <div class="col-md-3">
                <h6 class="text-info">Nómina de Ejecutores</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Nómina Semanal
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Nómina Quincenal
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Nómina Mensual
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-info me-2"></i>
                    Cálculo de Comisiones
                  </button>
                </div>
              </div>
              <div class="col-md-3">
                <h6 class="text-success">Estado de Folios</h6>
                <div class="list-group mb-3">
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Folios por Estado
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Efectividad de Notificación
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Tiempos de Respuesta
                  </button>
                  <button class="list-group-item list-group-item-action">
                    <i class="fas fa-file-excel text-success me-2"></i>
                    Análisis de Resultados
                  </button>
                </div>
              </div>
            </div>

            <!-- Criterios de Selección para Reportes -->
            <div class="card bg-light">
              <div class="card-body">
                <h6>🔧 Criterios de Selección para Reportes</h6>
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
                      <label class="form-label small">Ejecutor</label>
                      <select class="form-select form-select-sm">
                        <option>Todos</option>
                        <option>EJE-001</option>
                        <option>EJE-003</option>
                        <option>EJE-007</option>
                      </select>
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
                        <option>Poniente</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-2">
                    <div class="form-group mb-3">
                      <label class="form-label small">Estado</label>
                      <select class="form-select form-select-sm">
                        <option>Todos</option>
                        <option>Generado</option>
                        <option>Asignado</option>
                        <option>Notificado</option>
                        <option>Practicado</option>
                      </select>
                    </div>
                  </div>
                  <div class="col-md-2">
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
                <button class="btn btn-primary btn-sm">
                  <i class="fas fa-download"></i> Generar Reporte Personalizado
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
  name: 'SistemaApremiosRecaudadora'
}
</script>

<style scoped>
.sistema-apremios-recaudadora {
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

.timeline .card {
  border-left: 3px solid #007bff;
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