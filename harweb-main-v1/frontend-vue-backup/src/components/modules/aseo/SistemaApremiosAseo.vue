<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #fd7e14 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-warning bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-gavel fa-2x text-warning"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Apremios - Aseo</h1>
              <p class="text-muted mb-0">Gestión integral de procedimientos de cobranza para servicios de aseo</p>
            </div>
          </div>
          <div>
            <span class="badge bg-danger fs-6">NUEVO</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Pestañas -->
    <div class="card border-0 shadow-sm">
      <div class="card-header bg-white border-bottom">
        <ul class="nav nav-tabs card-header-tabs" id="apremiosTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button class="nav-link active" id="ejecutores-tab" data-bs-toggle="tab" data-bs-target="#ejecutores" type="button" role="tab">
              <i class="fas fa-users me-2"></i>Catálogo Ejecutores
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="folios-tab" data-bs-toggle="tab" data-bs-target="#folios" type="button" role="tab">
              <i class="fas fa-file-alt me-2"></i>Folios
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="impresion-tab" data-bs-toggle="tab" data-bs-target="#impresion" type="button" role="tab">
              <i class="fas fa-print me-2"></i>Impresión
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="modificacion-tab" data-bs-toggle="tab" data-bs-target="#modificacion" type="button" role="tab">
              <i class="fas fa-edit me-2"></i>Modificación
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="consulta-tab" data-bs-toggle="tab" data-bs-target="#consulta" type="button" role="tab">
              <i class="fas fa-search me-2"></i>Consulta
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="gestion-tab" data-bs-toggle="tab" data-bs-target="#gestion" type="button" role="tab">
              <i class="fas fa-cogs me-2"></i>Gestión Masiva
            </button>
          </li>
          <li class="nav-item" role="presentation">
            <button class="nav-link" id="reportes-tab" data-bs-toggle="tab" data-bs-target="#reportes" type="button" role="tab">
              <i class="fas fa-chart-line me-2"></i>Reportes
            </button>
          </li>
        </ul>
      </div>

      <div class="card-body p-4">
        <div class="tab-content" id="apremiosTabContent">

          <!-- Pestaña 1: Catálogo de Ejecutores -->
          <div class="tab-pane fade show active" id="ejecutores" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-warning mb-3">
                  <i class="fas fa-users me-2"></i>Catálogo de Ejecutores de Aseo
                </h4>
                <p class="text-muted mb-4">Gestión completa del personal ejecutor especializado en servicios de aseo</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Nombre Completo</label>
                    <input type="text" class="form-control" placeholder="Lic. Juan Pérez García">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Número de Empleado</label>
                    <input type="text" class="form-control" placeholder="ASE-001">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">RFC</label>
                    <input type="text" class="form-control" placeholder="PEGJ800101ABC">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">CURP</label>
                    <input type="text" class="form-control" placeholder="PEGJ800101HJCRNS01">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Zona de Recolección</label>
                    <select class="form-select">
                      <option>Seleccionar zona...</option>
                      <option>Zona 1 - Centro</option>
                      <option>Zona 2 - Norte</option>
                      <option>Zona 3 - Sur</option>
                      <option>Zona 4 - Oriente</option>
                      <option>Zona 5 - Poniente</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Especialización</label>
                    <select class="form-select">
                      <option>Cobranza Domiciliaria</option>
                      <option>Cobranza Comercial</option>
                      <option>Cobranza Industrial</option>
                      <option>Servicios Especiales</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Estado</label>
                    <select class="form-select">
                      <option>Activo</option>
                      <option>Inactivo</option>
                      <option>Capacitación</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Fecha de Alta</label>
                    <input type="date" class="form-control">
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-warning">
                    <i class="fas fa-plus me-2"></i>Agregar
                  </button>
                  <button class="btn btn-outline-warning">
                    <i class="fas fa-edit me-2"></i>Modificar
                  </button>
                  <button class="btn btn-outline-secondary">
                    <i class="fas fa-trash me-2"></i>Eliminar
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-recycle me-2"></i>Especialización
                  </h6>
                  <p class="small text-muted mb-2">• Personal capacitado en servicios de aseo</p>
                  <p class="small text-muted mb-2">• Asignación por zona de recolección</p>
                  <p class="small text-muted mb-0">• Conocimiento de rutas específicas</p>
                </div>

                <div class="mt-3 bg-primary bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-primary mb-2">
                    <i class="fas fa-chart-pie me-2"></i>Estadísticas
                  </h6>
                  <p class="small mb-1">Ejecutores Activos: <strong>8</strong></p>
                  <p class="small mb-1">Zonas Asignadas: <strong>5</strong></p>
                  <p class="small mb-0">Folios/Mes: <strong>89</strong></p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 2: Generación de Folios -->
          <div class="tab-pane fade" id="folios" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-warning mb-3">
                  <i class="fas fa-file-alt me-2"></i>Generación de Folios de Aseo
                </h4>
                <p class="text-muted mb-4">Sistema automatizado de folios para servicios de aseo urbano</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tipo de Notificación</label>
                    <select class="form-select">
                      <option>Adeudo de Servicio de Aseo</option>
                      <option>Requerimiento de Pago</option>
                      <option>Embargo por Servicio</option>
                      <option>Suspensión de Servicio</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Zona de Servicio</label>
                    <select class="form-select">
                      <option>Zona 1 - Centro</option>
                      <option>Zona 2 - Norte</option>
                      <option>Zona 3 - Sur</option>
                      <option>Zona 4 - Oriente</option>
                      <option>Zona 5 - Poniente</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Criterio de Selección</label>
                    <select class="form-select">
                      <option>Por Cuenta de Servicio</option>
                      <option>Por Monto de Adeudo</option>
                      <option>Por Tiempo de Vencimiento</option>
                      <option>Por Tipo de Usuario</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Valor del Criterio</label>
                    <input type="text" class="form-control" placeholder="Especifique el criterio...">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Ejecutor Asignado</label>
                    <select class="form-select">
                      <option>Seleccionar ejecutor...</option>
                      <option>Lic. Juan Pérez García (Zona 1)</option>
                      <option>Lic. María López Hernández (Zona 2)</option>
                      <option>Lic. Carlos Rodríguez Mendoza (Zona 3)</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Fundamento Legal</label>
                    <select class="form-select">
                      <option>Reglamento de Aseo Municipal</option>
                      <option>Ley de Ingresos Municipal</option>
                      <option>Código Fiscal Municipal</option>
                      <option>Reglamento de Servicios Públicos</option>
                    </select>
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-warning">
                    <i class="fas fa-plus me-2"></i>Generar Folios
                  </button>
                  <button class="btn btn-outline-warning">
                    <i class="fas fa-eye me-2"></i>Vista Previa
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-recycle me-2"></i>Especificaciones
                  </h6>
                  <p class="small text-muted mb-2">• Folios específicos para aseo</p>
                  <p class="small text-muted mb-2">• Consideración de rutas de recolección</p>
                  <p class="small text-muted mb-0">• Fundamentos legales municipales</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 3: Impresión de Folios -->
          <div class="tab-pane fade" id="impresion" role="tabpanel">
            <h4 class="fw-bold text-warning mb-3">
              <i class="fas fa-print me-2"></i>Impresión de Folios de Aseo
            </h4>
            <p class="text-muted mb-4">Generación de documentos oficiales con normativa municipal</p>

            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border border-warning border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-file-alt fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Notificación Individual</h5>
                    <p class="text-muted small mb-3">Impresión de folio específico</p>
                    <div class="row g-2 mb-3">
                      <div class="col-8">
                        <input type="text" class="form-control form-control-sm" placeholder="No. Folio">
                      </div>
                      <div class="col-4">
                        <button class="btn btn-warning btn-sm w-100">
                          <i class="fas fa-print"></i>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card border border-warning border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-layer-group fa-2x text-warning"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Impresión por Zona</h5>
                    <p class="text-muted small mb-3">Múltiples folios por zona de servicio</p>
                    <div class="row g-2 mb-3">
                      <div class="col-12">
                        <select class="form-select form-select-sm">
                          <option>Zona 1 - Centro</option>
                          <option>Zona 2 - Norte</option>
                          <option>Zona 3 - Sur</option>
                        </select>
                      </div>
                    </div>
                    <button class="btn btn-warning btn-sm">
                      <i class="fas fa-print me-2"></i>Imprimir Zona
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4 card border border-info border-opacity-25">
              <div class="card-header bg-info bg-opacity-10">
                <h6 class="fw-bold mb-0 text-info">
                  <i class="fas fa-recycle me-2"></i>Especificaciones de Aseo
                </h6>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p class="small mb-2">✓ Reglamento de Aseo Municipal</p>
                    <p class="small mb-2">✓ Fundamentos legales específicos</p>
                    <p class="small mb-0">✓ Formato Dirección de Servicios Públicos</p>
                  </div>
                  <div class="col-md-6">
                    <p class="small mb-2">✓ Identificación de zona de servicio</p>
                    <p class="small mb-2">✓ Ruta de recolección específica</p>
                    <p class="small mb-0">✓ Código de servicio municipal</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 4: Modificación de Folios -->
          <div class="tab-pane fade" id="modificacion" role="tabpanel">
            <h4 class="fw-bold text-warning mb-3">
              <i class="fas fa-edit me-2"></i>Modificación de Folios
            </h4>
            <p class="text-muted mb-4">Sistema de actualización de folios con seguimiento de cambios</p>

            <div class="row">
              <div class="col-lg-8">
                <div class="row g-3 mb-4">
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Número de Folio</label>
                    <input type="text" class="form-control" placeholder="ASE-2024-001">
                  </div>
                  <div class="col-md-8">
                    <label class="form-label fw-medium">&nbsp;</label>
                    <button class="btn btn-warning w-100">
                      <i class="fas fa-search me-2"></i>Buscar Folio de Aseo
                    </button>
                  </div>
                </div>

                <div class="card border border-warning border-opacity-50">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-recycle me-2"></i>Datos del Folio de Aseo
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Usuario del Servicio</label>
                        <input type="text" class="form-control" value="Juan Pérez García">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Cuenta de Servicio</label>
                        <input type="text" class="form-control" value="ASE-12345">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Zona de Servicio</label>
                        <select class="form-select">
                          <option selected>Zona 1 - Centro</option>
                          <option>Zona 2 - Norte</option>
                          <option>Zona 3 - Sur</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Tipo de Servicio</label>
                        <select class="form-select">
                          <option selected>Domiciliario</option>
                          <option>Comercial</option>
                          <option>Industrial</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Adeudo del Servicio</label>
                        <input type="number" class="form-control" value="2500.00" step="0.01">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Estado del Folio</label>
                        <select class="form-select">
                          <option>Pendiente</option>
                          <option selected>Notificado</option>
                          <option>En Proceso</option>
                          <option>Concluido</option>
                        </select>
                      </div>
                    </div>

                    <div class="mt-4 d-flex gap-2">
                      <button class="btn btn-warning">
                        <i class="fas fa-save me-2"></i>Guardar Cambios
                      </button>
                      <button class="btn btn-outline-secondary">
                        <i class="fas fa-history me-2"></i>Ver Historial
                      </button>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-warning bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-warning mb-2">
                    <i class="fas fa-recycle me-2"></i>Control de Servicios
                  </h6>
                  <p class="small text-muted mb-2">• Seguimiento por zona de recolección</p>
                  <p class="small text-muted mb-2">• Control de rutas específicas</p>
                  <p class="small text-muted mb-0">• Historial de modificaciones</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 5: Consulta de Folios -->
          <div class="tab-pane fade" id="consulta" role="tabpanel">
            <h4 class="fw-bold text-warning mb-3">
              <i class="fas fa-search me-2"></i>Consulta de Folios de Aseo
            </h4>
            <p class="text-muted mb-4">Sistema de consulta integral por zona y tipo de servicio</p>

            <div class="row g-3 mb-4">
              <div class="col-md-3">
                <label class="form-label fw-medium">Buscar por:</label>
                <select class="form-select">
                  <option>Número de Folio</option>
                  <option>Cuenta de Servicio</option>
                  <option>Usuario</option>
                  <option>Zona</option>
                  <option>Ejecutor</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-medium">Criterio de Búsqueda</label>
                <input type="text" class="form-control" placeholder="Ingrese el criterio...">
              </div>
              <div class="col-md-3">
                <label class="form-label fw-medium">&nbsp;</label>
                <button class="btn btn-warning w-100">
                  <i class="fas fa-search me-2"></i>Buscar
                </button>
              </div>
            </div>

            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-warning">
                  <tr>
                    <th>No. Folio</th>
                    <th>Usuario</th>
                    <th>Cuenta</th>
                    <th>Zona</th>
                    <th>Adeudo</th>
                    <th>Ejecutor</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>ASE-2024-001</strong></td>
                    <td>Juan Pérez García</td>
                    <td>ASE-12345</td>
                    <td>Zona 1</td>
                    <td>$2,500.00</td>
                    <td>Lic. Juan Pérez</td>
                    <td><span class="badge bg-warning">Notificado</span></td>
                    <td>
                      <button class="btn btn-sm btn-outline-warning">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>ASE-2024-002</strong></td>
                    <td>Comercial López</td>
                    <td>ASE-67890</td>
                    <td>Zona 2</td>
                    <td>$4,200.00</td>
                    <td>Lic. María López</td>
                    <td><span class="badge bg-success">Concluido</span></td>
                    <td>
                      <button class="btn btn-sm btn-outline-warning">
                        <i class="fas fa-eye"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Pestaña 6: Gestión Masiva -->
          <div class="tab-pane fade" id="gestion" role="tabpanel">
            <h4 class="fw-bold text-warning mb-3">
              <i class="fas fa-cogs me-2"></i>Gestión Masiva por Zona
            </h4>
            <p class="text-muted mb-4">Herramientas de procesamiento masivo para servicios de aseo</p>

            <div class="row g-4">
              <div class="col-md-4">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-user-plus fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Asignación por Zona</h6>
                    <p class="small text-muted mb-3">Asignar folios por zona de servicio</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-map me-2"></i>Asignar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-ban fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Cancelación Masiva</h6>
                    <p class="small text-muted mb-3">Cancelar folios por criterios</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-ban me-2"></i>Cancelar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-check-circle fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Practicar por Ruta</h6>
                    <p class="small text-muted mb-3">Ejecutar por ruta de recolección</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-route me-2"></i>Practicar
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4 card border border-secondary border-opacity-25">
              <div class="card-header bg-secondary bg-opacity-10">
                <h6 class="fw-bold mb-0">Filtros para Servicios de Aseo</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Por Zona</label>
                    <select class="form-select">
                      <option>Todas las zonas</option>
                      <option>Zona 1 - Centro</option>
                      <option>Zona 2 - Norte</option>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Por Tipo</label>
                    <select class="form-select">
                      <option>Todos los tipos</option>
                      <option>Domiciliario</option>
                      <option>Comercial</option>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Por Estado</label>
                    <select class="form-select">
                      <option>Todos</option>
                      <option>Pendiente</option>
                      <option>Notificado</option>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Por Fecha</label>
                    <input type="date" class="form-control">
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 7: Reportes -->
          <div class="tab-pane fade" id="reportes" role="tabpanel">
            <h4 class="fw-bold text-warning mb-3">
              <i class="fas fa-chart-line me-2"></i>Reportes de Aseo
            </h4>
            <p class="text-muted mb-4">Sistema de reportes especializados para servicios de aseo</p>

            <div class="row g-4">
              <div class="col-md-6 col-lg-3">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-users fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Ejecutores de Aseo</h6>
                    <p class="small text-muted mb-3">Personal especializado</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6 col-lg-3">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-percentage fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Descuentos por Zona</h6>
                    <p class="small text-muted mb-3">Descuentos aplicados</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6 col-lg-3">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-money-bill fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Nómina Ejecutores</h6>
                    <p class="small text-muted mb-3">Pagos por zona</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6 col-lg-3">
                <div class="card border border-warning border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-warning bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-chart-bar fa-2x text-warning"></i>
                    </div>
                    <h6 class="fw-bold">Estado por Zona</h6>
                    <p class="small text-muted mb-3">Folios por zona</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
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
</template>

<script>
export default {
  name: 'SistemaApremiosAseo',
  data() {
    return {
      // Estado del componente
    }
  },
  methods: {
    // Métodos del componente
  }
}
</script>

<style scoped>
.nav-tabs .nav-link {
  border-bottom: 2px solid transparent;
  color: #6c757d;
}

.nav-tabs .nav-link.active {
  border-bottom-color: #fd7e14;
  color: #fd7e14;
  font-weight: 600;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #fd7e14;
  color: #fd7e14;
}
</style>