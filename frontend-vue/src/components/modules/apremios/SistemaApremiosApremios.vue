<template>
  <div class="container-fluid mt-4">
    <!-- Header del Sistema -->
    <div class="card border-0 shadow-sm mb-4" style="border-left: 5px solid #198754 !important;">
      <div class="card-body p-4">
        <div class="d-flex align-items-center justify-content-between">
          <div class="d-flex align-items-center">
            <div class="bg-success bg-opacity-10 rounded-3 p-3 me-3">
              <i class="fas fa-gavel fa-2x text-success"></i>
            </div>
            <div>
              <h1 class="h3 fw-bold text-dark mb-1">Sistema de Apremios</h1>
              <p class="text-muted mb-0">Gestión integral de procedimientos administrativos de apremio</p>
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
                <h4 class="fw-bold text-success mb-3">
                  <i class="fas fa-users me-2"></i>Catálogo de Ejecutores
                </h4>
                <p class="text-muted mb-4">Gestión completa del personal ejecutor de procedimientos administrativos</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Nombre Completo</label>
                    <input type="text" class="form-control" placeholder="Lic. Juan Pérez García">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Número de Empleado</label>
                    <input type="text" class="form-control" placeholder="EMP-001">
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
                    <label class="form-label fw-medium">Zona Asignada</label>
                    <select class="form-select">
                      <option>Seleccionar zona...</option>
                      <option>Zona Centro</option>
                      <option>Zona Norte</option>
                      <option>Zona Sur</option>
                      <option>Zona Oriente</option>
                      <option>Zona Poniente</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Estado</label>
                    <select class="form-select">
                      <option>Activo</option>
                      <option>Inactivo</option>
                      <option>Suspendido</option>
                    </select>
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-success">
                    <i class="fas fa-plus me-2"></i>Agregar
                  </button>
                  <button class="btn btn-outline-success">
                    <i class="fas fa-edit me-2"></i>Modificar
                  </button>
                  <button class="btn btn-outline-secondary">
                    <i class="fas fa-trash me-2"></i>Eliminar
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-success bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-success mb-2">
                    <i class="fas fa-info-circle me-2"></i>Información
                  </h6>
                  <p class="small text-muted mb-2">• Control de personal especializado</p>
                  <p class="small text-muted mb-2">• Asignación de zonas geográficas</p>
                  <p class="small text-muted mb-0">• Seguimiento de capacitaciones</p>
                </div>

                <div class="mt-3 bg-primary bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-primary mb-2">
                    <i class="fas fa-chart-pie me-2"></i>Estadísticas
                  </h6>
                  <p class="small mb-1">Ejecutores Activos: <strong>12</strong></p>
                  <p class="small mb-1">Zonas Cubiertas: <strong>5</strong></p>
                  <p class="small mb-0">Promedio Folios/Mes: <strong>156</strong></p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 2: Generación de Folios -->
          <div class="tab-pane fade" id="folios" role="tabpanel">
            <div class="row">
              <div class="col-lg-8">
                <h4 class="fw-bold text-success mb-3">
                  <i class="fas fa-file-alt me-2"></i>Generación de Folios
                </h4>
                <p class="text-muted mb-4">Sistema automatizado de generación de folios de notificación y requerimientos</p>

                <div class="row g-3 mb-4">
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Tipo de Documento</label>
                    <select class="form-select">
                      <option>Notificación de Adeudo</option>
                      <option>Requerimiento de Pago</option>
                      <option>Embargo Precautorio</option>
                      <option>Mandamiento de Ejecución</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Criterio de Selección</label>
                    <select class="form-select">
                      <option>Por RFC</option>
                      <option>Por Rango de Adeudo</option>
                      <option>Por Zona Geográfica</option>
                      <option>Por Fecha de Vencimiento</option>
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
                      <option>Lic. Juan Pérez García</option>
                      <option>Lic. María López Hernández</option>
                      <option>Lic. Carlos Rodríguez Mendoza</option>
                    </select>
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Fecha de Notificación</label>
                    <input type="date" class="form-control">
                  </div>
                  <div class="col-md-6">
                    <label class="form-label fw-medium">Fundamento Legal</label>
                    <select class="form-select">
                      <option>Artículo 21 CFF</option>
                      <option>Artículo 145 CFF</option>
                      <option>Artículo 151 CFF</option>
                      <option>Código Fiscal Municipal</option>
                    </select>
                  </div>
                </div>

                <div class="d-flex gap-2 mb-4">
                  <button class="btn btn-success">
                    <i class="fas fa-plus me-2"></i>Generar Folios
                  </button>
                  <button class="btn btn-outline-success">
                    <i class="fas fa-eye me-2"></i>Vista Previa
                  </button>
                </div>
              </div>

              <div class="col-lg-4">
                <div class="bg-success bg-opacity-10 rounded-3 p-3">
                  <h6 class="fw-bold text-success mb-2">
                    <i class="fas fa-cog me-2"></i>Configuración
                  </h6>
                  <p class="small text-muted mb-2">• Numeración automática consecutiva</p>
                  <p class="small text-muted mb-2">• Aplicación de fundamentos legales</p>
                  <p class="small text-muted mb-0">• Formato Dirección Política Fiscal</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 3: Impresión de Folios -->
          <div class="tab-pane fade" id="impresion" role="tabpanel">
            <h4 class="fw-bold text-success mb-3">
              <i class="fas fa-print me-2"></i>Impresión de Folios
            </h4>
            <p class="text-muted mb-4">Generación de documentos oficiales con fundamentos legales</p>

            <div class="row g-4">
              <div class="col-md-6">
                <div class="card border border-success border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-file-alt fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Notificación Individual</h5>
                    <p class="text-muted small mb-3">Impresión de folio específico</p>
                    <div class="row g-2 mb-3">
                      <div class="col-8">
                        <input type="text" class="form-control form-control-sm" placeholder="No. Folio">
                      </div>
                      <div class="col-4">
                        <button class="btn btn-success btn-sm w-100">
                          <i class="fas fa-print"></i>
                        </button>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <div class="col-md-6">
                <div class="card border border-success border-opacity-25">
                  <div class="card-body text-center">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-files-o fa-2x text-success"></i>
                    </div>
                    <h5 class="fw-bold text-dark">Impresión Masiva</h5>
                    <p class="text-muted small mb-3">Múltiples folios por criterios</p>
                    <div class="row g-2 mb-3">
                      <div class="col-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Desde">
                      </div>
                      <div class="col-6">
                        <input type="text" class="form-control form-control-sm" placeholder="Hasta">
                      </div>
                    </div>
                    <button class="btn btn-success btn-sm">
                      <i class="fas fa-print me-2"></i>Imprimir Lote
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4 card border border-info border-opacity-25">
              <div class="card-header bg-info bg-opacity-10">
                <h6 class="fw-bold mb-0 text-info">
                  <i class="fas fa-info-circle me-2"></i>Especificaciones del Documento
                </h6>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-6">
                    <p class="small mb-2">✓ Formato oficial de la Dirección de Política Fiscal</p>
                    <p class="small mb-2">✓ Fundamentos legales específicos</p>
                    <p class="small mb-0">✓ Elementos de seguridad integrados</p>
                  </div>
                  <div class="col-md-6">
                    <p class="small mb-2">✓ Numeración consecutiva automática</p>
                    <p class="small mb-2">✓ Fecha y hora de generación</p>
                    <p class="small mb-0">✓ Código de barras para seguimiento</p>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 4: Modificación de Folios -->
          <div class="tab-pane fade" id="modificacion" role="tabpanel">
            <h4 class="fw-bold text-success mb-3">
              <i class="fas fa-edit me-2"></i>Modificación de Folios
            </h4>
            <p class="text-muted mb-4">Sistema de actualización de folios generados con control de versiones</p>

            <div class="row">
              <div class="col-lg-8">
                <div class="row g-3 mb-4">
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Número de Folio</label>
                    <input type="text" class="form-control" placeholder="APR-2024-001">
                  </div>
                  <div class="col-md-8">
                    <label class="form-label fw-medium">&nbsp;</label>
                    <button class="btn btn-success w-100">
                      <i class="fas fa-search me-2"></i>Buscar Folio
                    </button>
                  </div>
                </div>

                <div class="card border border-warning border-opacity-50">
                  <div class="card-header bg-warning bg-opacity-10">
                    <h6 class="fw-bold mb-0 text-warning">
                      <i class="fas fa-edit me-2"></i>Datos del Folio
                    </h6>
                  </div>
                  <div class="card-body">
                    <div class="row g-3">
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Contribuyente</label>
                        <input type="text" class="form-control" value="Juan Pérez García">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">RFC</label>
                        <input type="text" class="form-control" value="PEGJ800101ABC">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Domicilio</label>
                        <textarea class="form-control" rows="2">Av. Hidalgo #123, Col. Centro</textarea>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Adeudo</label>
                        <input type="number" class="form-control" value="15000.00" step="0.01">
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Ejecutor Asignado</label>
                        <select class="form-select">
                          <option selected>Lic. Juan Pérez García</option>
                          <option>Lic. María López Hernández</option>
                          <option>Lic. Carlos Rodríguez Mendoza</option>
                        </select>
                      </div>
                      <div class="col-md-6">
                        <label class="form-label fw-medium">Estado</label>
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
                    <i class="fas fa-exclamation-triangle me-2"></i>Control de Versiones
                  </h6>
                  <p class="small text-muted mb-2">• Historial completo de modificaciones</p>
                  <p class="small text-muted mb-2">• Usuario y fecha de cambios</p>
                  <p class="small text-muted mb-0">• Trazabilidad completa</p>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 5: Consulta de Folios -->
          <div class="tab-pane fade" id="consulta" role="tabpanel">
            <h4 class="fw-bold text-success mb-3">
              <i class="fas fa-search me-2"></i>Consulta de Folios
            </h4>
            <p class="text-muted mb-4">Sistema de consulta integral con múltiples criterios de búsqueda</p>

            <div class="row g-3 mb-4">
              <div class="col-md-3">
                <label class="form-label fw-medium">Buscar por:</label>
                <select class="form-select">
                  <option>Número de Folio</option>
                  <option>RFC</option>
                  <option>Contribuyente</option>
                  <option>Ejecutor</option>
                  <option>Estado</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label fw-medium">Criterio de Búsqueda</label>
                <input type="text" class="form-control" placeholder="Ingrese el criterio...">
              </div>
              <div class="col-md-3">
                <label class="form-label fw-medium">&nbsp;</label>
                <button class="btn btn-success w-100">
                  <i class="fas fa-search me-2"></i>Buscar
                </button>
              </div>
            </div>

            <div class="table-responsive">
              <table class="table table-hover">
                <thead class="table-success">
                  <tr>
                    <th>No. Folio</th>
                    <th>Contribuyente</th>
                    <th>RFC</th>
                    <th>Adeudo</th>
                    <th>Ejecutor</th>
                    <th>Estado</th>
                    <th>Fecha</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td><strong>APR-2024-001</strong></td>
                    <td>Juan Pérez García</td>
                    <td>PEGJ800101ABC</td>
                    <td>$15,000.00</td>
                    <td>Lic. Juan Pérez</td>
                    <td><span class="badge bg-warning">Notificado</span></td>
                    <td>15/10/2024</td>
                    <td>
                      <button class="btn btn-sm btn-outline-success">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-outline-primary">
                        <i class="fas fa-edit"></i>
                      </button>
                    </td>
                  </tr>
                  <tr>
                    <td><strong>APR-2024-002</strong></td>
                    <td>María López Hernández</td>
                    <td>LOHM850215XYZ</td>
                    <td>$8,500.00</td>
                    <td>Lic. María López</td>
                    <td><span class="badge bg-success">Concluido</span></td>
                    <td>12/10/2024</td>
                    <td>
                      <button class="btn btn-sm btn-outline-success">
                        <i class="fas fa-eye"></i>
                      </button>
                      <button class="btn btn-sm btn-outline-primary">
                        <i class="fas fa-edit"></i>
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Pestaña 6: Gestión Masiva -->
          <div class="tab-pane fade" id="gestion" role="tabpanel">
            <h4 class="fw-bold text-success mb-3">
              <i class="fas fa-cogs me-2"></i>Gestión Masiva de Folios
            </h4>
            <p class="text-muted mb-4">Herramientas de procesamiento masivo para eficiencia operativa</p>

            <div class="row g-4">
              <div class="col-md-4">
                <div class="card border border-success border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-user-plus fa-2x text-success"></i>
                    </div>
                    <h6 class="fw-bold">Asignación Masiva</h6>
                    <p class="small text-muted mb-3">Asignar múltiples folios a ejecutores</p>
                    <button class="btn btn-outline-success btn-sm">
                      <i class="fas fa-users me-2"></i>Asignar
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
                    <p class="small text-muted mb-3">Cancelar folios por criterios específicos</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-ban me-2"></i>Cancelar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-4">
                <div class="card border border-info border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-check-circle fa-2x text-info"></i>
                    </div>
                    <h6 class="fw-bold">Practicar Folios</h6>
                    <p class="small text-muted mb-3">Ejecutar procedimientos masivamente</p>
                    <button class="btn btn-outline-info btn-sm">
                      <i class="fas fa-play me-2"></i>Practicar
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4 card border border-secondary border-opacity-25">
              <div class="card-header bg-secondary bg-opacity-10">
                <h6 class="fw-bold mb-0">Criterios para Procesamiento Masivo</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Por Ejecutor</label>
                    <select class="form-select">
                      <option>Todos los ejecutores</option>
                      <option>Lic. Juan Pérez García</option>
                      <option>Lic. María López Hernández</option>
                    </select>
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Por Estado</label>
                    <select class="form-select">
                      <option>Pendiente</option>
                      <option>Notificado</option>
                      <option>En Proceso</option>
                    </select>
                  </div>
                  <div class="col-md-4">
                    <label class="form-label fw-medium">Por Fecha</label>
                    <input type="date" class="form-control">
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Pestaña 7: Reportes -->
          <div class="tab-pane fade" id="reportes" role="tabpanel">
            <h4 class="fw-bold text-success mb-3">
              <i class="fas fa-chart-line me-2"></i>Reportes Especializados
            </h4>
            <p class="text-muted mb-4">Sistema de reportes para análisis y control administrativo</p>

            <div class="row g-4">
              <div class="col-md-6 col-lg-3">
                <div class="card border border-success border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-success bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-users fa-2x text-success"></i>
                    </div>
                    <h6 class="fw-bold">Catálogo de Ejecutores</h6>
                    <p class="small text-muted mb-3">Listado completo del personal</p>
                    <button class="btn btn-outline-success btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6 col-lg-3">
                <div class="card border border-info border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-info bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-percentage fa-2x text-info"></i>
                    </div>
                    <h6 class="fw-bold">Listado de Descuentos</h6>
                    <p class="small text-muted mb-3">Descuentos aplicados</p>
                    <button class="btn btn-outline-info btn-sm">
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
                    <p class="small text-muted mb-3">Pagos por folios ejecutados</p>
                    <button class="btn btn-outline-warning btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>

              <div class="col-md-6 col-lg-3">
                <div class="card border border-primary border-opacity-25 h-100">
                  <div class="card-body text-center">
                    <div class="bg-primary bg-opacity-10 rounded-circle p-3 d-inline-flex mb-3">
                      <i class="fas fa-chart-bar fa-2x text-primary"></i>
                    </div>
                    <h6 class="fw-bold">Estado de Folios</h6>
                    <p class="small text-muted mb-3">Por ejecutor y período</p>
                    <button class="btn btn-outline-primary btn-sm">
                      <i class="fas fa-file-excel me-2"></i>Exportar
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div class="mt-4 card border border-secondary border-opacity-25">
              <div class="card-header bg-secondary bg-opacity-10">
                <h6 class="fw-bold mb-0">Filtros de Reportes</h6>
              </div>
              <div class="card-body">
                <div class="row g-3">
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Período Desde</label>
                    <input type="date" class="form-control">
                  </div>
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Período Hasta</label>
                    <input type="date" class="form-control">
                  </div>
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Ejecutor</label>
                    <select class="form-select">
                      <option>Todos</option>
                      <option>Lic. Juan Pérez García</option>
                      <option>Lic. María López Hernández</option>
                    </select>
                  </div>
                  <div class="col-md-3">
                    <label class="form-label fw-medium">Estado</label>
                    <select class="form-select">
                      <option>Todos</option>
                      <option>Pendiente</option>
                      <option>Concluido</option>
                    </select>
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
  name: 'SistemaApremiosApremios',
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
  border-bottom-color: #198754;
  color: #198754;
  font-weight: 600;
}

.nav-tabs .nav-link:hover {
  border-bottom-color: #198754;
  color: #198754;
}
</style>