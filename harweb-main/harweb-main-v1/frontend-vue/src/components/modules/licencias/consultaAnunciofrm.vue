<template>
  <div class="container-fluid p-0 h-100 module-layout municipal-page">
    <div class="consulta-anuncio-container">
    <!-- Municipal Header -->
    <div class="municipal-header mb-4">
      <div class="row align-items-center">
        <div class="col">
          <h2 class="municipal-title mb-0">
            <i class="fas fa-bullhorn"></i>
            Consulta de Anuncios
          </h2>
          <p class="municipal-subtitle mb-0">Gestión de requerimientos de anuncios publicitarios</p>
        </div>
        <div class="col-auto">
          <button
            class="btn btn-primary municipal-btn-primary"
            @click="showCreateModal = true"
            :disabled="loading"
          >
            <i class="fas fa-plus me-2"></i>
            Nuevo Requerimiento
          </button>
        </div>
      </div>
    </div>

    <!-- Municipal Filtros y búsqueda -->
    <div class="municipal-card mb-4">
      <div class="card-body">
        <div class="row g-3">
          <div class="col-md-8">
            <div class="input-group">
              <span class="input-group-text municipal-input-group">
                <i class="fas fa-search"></i>
              </span>
              <input
                v-model="searchTerm"
                type="text"
                class="form-control municipal-input"
                placeholder="Buscar por CVE REQ, ID Anuncio, Folio o Capturista..."
                @input="debounceSearch"
              />
            </div>
          </div>
          <div class="col-md-4">
            <div class="btn-group municipal-group-btn w-100" role="group">
              <button
                class="btn btn-outline-primary municipal-btn-primary"
                @click="refreshData"
                :disabled="loading"
              >
                <i class="fas fa-sync-alt me-2"></i>
                Actualizar
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Estadísticas -->
    <div class="row mb-4">
      <div class="col-lg-3 col-md-6 mb-3">
        <div class="card border-primary">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="me-3">
                <i class="fas fa-clipboard-list fa-2x text-primary"></i>
              </div>
              <div>
                <h6 class="card-title mb-0">Total Requerimientos</h6>
                <h4 class="mb-0">{{ totalRecords.toLocaleString() }}</h4>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-lg-3 col-md-6 mb-3">
        <div class="card border-success">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="me-3">
                <i class="fas fa-check-circle fa-2x text-success"></i>
              </div>
              <div>
                <h6 class="card-title mb-0">Vigentes</h6>
                <h4 class="mb-0">{{ stats.vigentes || 0 }}</h4>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-lg-3 col-md-6 mb-3">
        <div class="card border-warning">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="me-3">
                <i class="fas fa-exclamation-triangle fa-2x text-warning"></i>
              </div>
              <div>
                <h6 class="card-title mb-0">En Proceso</h6>
                <h4 class="mb-0">{{ stats.proceso || 0 }}</h4>
              </div>
            </div>
          </div>
        </div>
      </div>
      <div class="col-lg-3 col-md-6 mb-3">
        <div class="card border-info">
          <div class="card-body">
            <div class="d-flex align-items-center">
              <div class="me-3">
                <i class="fas fa-dollar-sign fa-2x text-info"></i>
              </div>
              <div>
                <h6 class="card-title mb-0">Total Importe</h6>
                <h4 class="mb-0">${{ totalImporte.toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</h4>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Municipal Tabla de datos -->
    <div class="municipal-card">
      <div class="card-header municipal-table-header">
        <h6 class="mb-0">
          <i class="fas fa-list"></i>
          Requerimientos de Anuncios
          <span v-if="!loading" class="badge bg-light text-dark ms-2">{{ anuncios.length }}</span>
        </h6>
      </div>

      <div class="card-body p-0">
        <!-- Loading -->
        <div v-if="loading && anuncios.length === 0" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Cargando...</span>
          </div>
          <p class="mt-2 text-muted">Cargando requerimientos...</p>
        </div>

        <!-- Error -->
        <div v-else-if="error" class="alert alert-danger m-3">
          <h6 class="alert-heading">Error al cargar datos</h6>
          <p class="mb-0">{{ error }}</p>
          <hr>
          <button class="btn btn-sm btn-outline-danger" @click="refreshData">
            Reintentar
          </button>
        </div>

        <!-- Sin datos -->
        <div v-else-if="anuncios.length === 0" class="text-center py-4">
          <i class="fas fa-inbox fa-3x text-muted mb-3"></i>
          <h6 class="text-muted">No hay requerimientos</h6>
          <p class="text-muted">No se encontraron requerimientos de anuncios con los criterios especificados</p>
        </div>

        <!-- Municipal Tabla Bootstrap -->
        <div v-else class="table-responsive">
          <table class="table table-hover municipal-table mb-0">
            <thead class="municipal-table-header-row">
              <tr>
                <th scope="col" class="text-center">
                  <i class="fas fa-hashtag me-1"></i>CVE REQ
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-bullhorn me-1"></i>ID Anuncio
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-file-alt me-1"></i>Folio
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-calendar me-1"></i>Año
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-building me-1"></i>Recaud
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-cog me-1"></i>Proceso
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-check-circle me-1"></i>Vigencia
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-dollar-sign me-1"></i>Total
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-calendar-check me-1"></i>Fecha Emisión
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-user me-1"></i>Capturista
                </th>
                <th scope="col" class="text-center">
                  <i class="fas fa-tools me-1"></i>Acciones
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="anuncio in anuncios" :key="anuncio.cvereq" class="align-middle">
                <td class="text-center">
                  <strong class="text-primary fs-6">{{ anuncio.cvereq }}</strong>
                </td>
                <td class="text-center">
                  <span class="badge bg-info text-dark">{{ anuncio.id_anuncio || 'N/A' }}</span>
                </td>
                <td class="text-center">
                  <span class="text-muted">{{ anuncio.folioreq || 'N/A' }}</span>
                </td>
                <td class="text-center">
                  <span class="badge bg-secondary">{{ anuncio.axoreq || 'N/A' }}</span>
                </td>
                <td class="text-center">
                  <span class="badge bg-light text-dark">{{ getRecaudText(anuncio.recaud) }}</span>
                </td>
                <td class="text-center">
                  <span class="badge" :class="getProcesoClass(anuncio.cveproceso)">
                    {{ getProcesoText(anuncio.cveproceso) }}
                  </span>
                </td>
                <td class="text-center">
                  <span class="badge" :class="getVigenciaClass(anuncio.vigencia)">
                    {{ getVigenciaText(anuncio.vigencia) }}
                  </span>
                </td>
                <td class="text-end">
                  <strong class="text-success fs-6">
                    ${{ parseFloat(anuncio.total || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}
                  </strong>
                </td>
                <td class="text-center">
                  <small class="text-muted">{{ formatDate(anuncio.fecemi) }}</small>
                </td>
                <td class="text-center">
                  <code class="bg-light px-2 py-1 rounded">{{ anuncio.capturista || 'N/A' }}</code>
                </td>
                <td class="text-center">
                  <div class="btn-group btn-group-sm municipal-group-btn" role="group">
                    <button
                      type="button"
                      class="btn btn-outline-primary municipal-btn-primary"
                      @click="viewAnuncio(anuncio)"
                      title="Ver detalles"
                      data-bs-toggle="tooltip"
                    >
                      <i class="fas fa-eye"></i>
                    </button>
                    <button
                      type="button"
                      class="btn btn-outline-secondary municipal-btn-secondary"
                      @click="editAnuncio(anuncio)"
                      title="Editar"
                      data-bs-toggle="tooltip"
                    >
                      <i class="fas fa-edit"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <!-- Paginación Bootstrap -->
        <div v-if="anuncios.length > 0" class="card-footer bg-light">
          <div class="row align-items-center justify-content-between">
            <div class="col-md-6">
              <div class="d-flex align-items-center">
                <small class="text-muted me-3">
                  Mostrando {{ ((currentPage - 1) * pageSize) + 1 }} a {{ Math.min(currentPage * pageSize, totalRecords) }} de {{ totalRecords.toLocaleString() }} registros
                </small>
                <div class="input-group input-group-sm" style="width: 150px;">
                  <span class="input-group-text">Mostrar</span>
                  <select v-model="pageSize" @change="changePageSize" class="form-select form-select-sm">
                    <option value="10">10</option>
                    <option value="20">20</option>
                    <option value="50">50</option>
                    <option value="100">100</option>
                  </select>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <nav aria-label="Navegación de páginas">
                <ul class="pagination pagination-sm justify-content-end mb-0">
                  <!-- Primera página -->
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="changePage(1)" :disabled="currentPage === 1" title="Primera página">
                      <i class="fas fa-angle-double-left"></i>
                    </button>
                  </li>

                  <!-- Página anterior -->
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="changePage(currentPage - 1)" :disabled="currentPage === 1" title="Página anterior">
                      <i class="fas fa-angle-left"></i>
                    </button>
                  </li>

                  <!-- Páginas numeradas -->
                  <li v-for="page in visiblePages" :key="page" class="page-item" :class="{ active: page === currentPage }">
                    <button v-if="page === '...'" class="page-link" disabled>...</button>
                    <button v-else class="page-link" @click="changePage(page)">{{ page }}</button>
                  </li>

                  <!-- Página siguiente -->
                  <li class="page-item" :class="{ disabled: !hasMorePages }">
                    <button class="page-link" @click="changePage(currentPage + 1)" :disabled="!hasMorePages" title="Página siguiente">
                      <i class="fas fa-angle-right"></i>
                    </button>
                  </li>

                  <!-- Última página -->
                  <li class="page-item" :class="{ disabled: !hasMorePages }">
                    <button class="page-link" @click="changePage(totalPages)" :disabled="!hasMorePages" title="Última página">
                      <i class="fas fa-angle-double-right"></i>
                    </button>
                  </li>
                </ul>
              </nav>
            </div>
          </div>

          <!-- Información adicional de paginación -->
          <div class="row mt-2">
            <div class="col">
              <small class="text-muted d-block">
                <i class="fas fa-info-circle me-1"></i>
                Página {{ currentPage }} de {{ totalPages }}
                <span class="badge bg-primary ms-2">{{ totalRecords.toLocaleString() }} total</span>
              </small>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Ver Detalles Bootstrap -->
    <div v-if="showViewModal" class="modal fade show d-block" tabindex="-1" aria-labelledby="modalDetalleLabel" aria-hidden="false">
      <div class="modal-dialog modal-xl modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header bg-primary text-white">
            <h5 class="modal-title" id="modalDetalleLabel">
              <i class="fas fa-eye me-2"></i>
              Detalles del Requerimiento <span class="badge bg-light text-dark ms-2">{{ selectedAnuncio?.cvereq }}</span>
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="showViewModal = false" aria-label="Cerrar"></button>
          </div>
          <div class="modal-body p-4">
            <div v-if="selectedAnuncio">
              <!-- Información Básica -->
              <div class="row mb-4">
                <div class="col-md-6">
                  <div class="card h-100">
                    <div class="card-header bg-info text-white">
                      <h6 class="mb-0"><i class="fas fa-info-circle me-2"></i>Información Básica</h6>
                    </div>
                    <div class="card-body">
                      <table class="table table-sm table-borderless">
                        <tr>
                          <td class="fw-bold text-muted">CVE REQ:</td>
                          <td><span class="badge bg-primary">{{ selectedAnuncio.cvereq }}</span></td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">ID Anuncio:</td>
                          <td><span class="badge bg-info text-dark">{{ selectedAnuncio.id_anuncio }}</span></td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Folio:</td>
                          <td>{{ selectedAnuncio.folioreq }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Año:</td>
                          <td><span class="badge bg-secondary">{{ selectedAnuncio.axoreq }}</span></td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Recaudadora:</td>
                          <td><span class="badge bg-light text-dark">{{ selectedAnuncio.recaud }}</span></td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Tipo Licencia:</td>
                          <td><span class="badge bg-warning text-dark">{{ selectedAnuncio.tipolic }}</span></td>
                        </tr>
                      </table>
                    </div>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="card h-100">
                    <div class="card-header bg-success text-white">
                      <h6 class="mb-0"><i class="fas fa-dollar-sign me-2"></i>Importes</h6>
                    </div>
                    <div class="card-body">
                      <table class="table table-sm table-borderless">
                        <tr>
                          <td class="fw-bold text-muted">Derechos:</td>
                          <td class="text-end">${{ parseFloat(selectedAnuncio.derechos || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Recargos:</td>
                          <td class="text-end">${{ parseFloat(selectedAnuncio.recargos || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Formas:</td>
                          <td class="text-end">${{ parseFloat(selectedAnuncio.formas || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Gastos:</td>
                          <td class="text-end">${{ parseFloat(selectedAnuncio.gastos || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Multa:</td>
                          <td class="text-end">${{ parseFloat(selectedAnuncio.multa || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</td>
                        </tr>
                        <tr class="border-top border-2 border-success">
                          <td class="fw-bold text-success fs-6">Total:</td>
                          <td class="text-end fw-bold text-success fs-5">${{ parseFloat(selectedAnuncio.total || 0).toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</td>
                        </tr>
                      </table>
                    </div>
                  </div>
                </div>
              </div>
              <!-- Fechas y Estado -->
              <div class="row">
                <div class="col-md-6">
                  <div class="card h-100">
                    <div class="card-header bg-warning text-dark">
                      <h6 class="mb-0"><i class="fas fa-calendar me-2"></i>Fechas</h6>
                    </div>
                    <div class="card-body">
                      <table class="table table-sm table-borderless">
                        <tr>
                          <td class="fw-bold text-muted">Fecha Emisión:</td>
                          <td>
                            <span class="badge bg-primary">
                              <i class="fas fa-calendar-plus me-1"></i>{{ formatDate(selectedAnuncio.fecemi) }}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Fecha Entrega Ejecutor:</td>
                          <td>
                            <span class="badge bg-info text-dark">
                              <i class="fas fa-calendar-check me-1"></i>{{ formatDate(selectedAnuncio.fecentejec) }}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Fecha Citatorio:</td>
                          <td>
                            <span class="badge bg-warning text-dark">
                              <i class="fas fa-calendar-alt me-1"></i>{{ formatDate(selectedAnuncio.feccit) }}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Fecha Práctica:</td>
                          <td>
                            <span class="badge bg-success">
                              <i class="fas fa-calendar-day me-1"></i>{{ formatDate(selectedAnuncio.fecprac) }}
                            </span>
                          </td>
                        </tr>
                      </table>
                    </div>
                  </div>
                </div>
                <div class="col-md-6">
                  <div class="card h-100">
                    <div class="card-header bg-secondary text-white">
                      <h6 class="mb-0"><i class="fas fa-cogs me-2"></i>Estado y Control</h6>
                    </div>
                    <div class="card-body">
                      <table class="table table-sm table-borderless">
                        <tr>
                          <td class="fw-bold text-muted">Vigencia:</td>
                          <td>
                            <span class="badge" :class="getVigenciaClass(selectedAnuncio.vigencia)">
                              <i class="fas fa-check-circle me-1"></i>{{ getVigenciaText(selectedAnuncio.vigencia) }}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Proceso:</td>
                          <td>
                            <span class="badge" :class="getProcesoClass(selectedAnuncio.cveproceso)">
                              <i class="fas fa-cog me-1"></i>{{ getProcesoText(selectedAnuncio.cveproceso) }}
                            </span>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Capturista:</td>
                          <td>
                            <code class="bg-light px-2 py-1 rounded">
                              <i class="fas fa-user me-1"></i>{{ selectedAnuncio.capturista }}
                            </code>
                          </td>
                        </tr>
                        <tr>
                          <td class="fw-bold text-muted">Ejecutor:</td>
                          <td>
                            <span class="badge bg-dark">
                              <i class="fas fa-gavel me-1"></i>{{ selectedAnuncio.cveejecut || 'N/A' }}
                            </span>
                          </td>
                        </tr>
                      </table>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Observaciones -->
              <div v-if="selectedAnuncio.obs" class="row mt-4">
                <div class="col-12">
                  <div class="card">
                    <div class="card-header bg-light">
                      <h6 class="mb-0"><i class="fas fa-comment-alt me-2"></i>Observaciones</h6>
                    </div>
                    <div class="card-body">
                      <div class="alert alert-info mb-0">
                        <i class="fas fa-info-circle me-2"></i>{{ selectedAnuncio.obs }}
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer bg-light">
            <div class="d-flex justify-content-between w-100">
              <div>
                <button type="button" class="btn btn-outline-primary me-2" @click="editAnuncio(selectedAnuncio)">
                  <i class="fas fa-edit me-2"></i>Editar Requerimiento
                </button>
                <button type="button" class="btn btn-outline-info" @click="printDetails">
                  <i class="fas fa-print me-2"></i>Imprimir
                </button>
              </div>
              <div>
                <button type="button" class="btn btn-secondary" @click="showViewModal = false">
                  <i class="fas fa-times me-2"></i>Cerrar
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Editar Requerimiento Bootstrap -->
    <div v-if="showEditModal" class="modal fade show d-block" tabindex="-1" aria-labelledby="modalEditarLabel" aria-hidden="false">
      <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header bg-warning text-dark">
            <h5 class="modal-title" id="modalEditarLabel">
              <i class="fas fa-edit me-2"></i>
              Editar Requerimiento <span class="badge bg-dark text-white ms-2">{{ selectedAnuncio?.cvereq }}</span>
            </h5>
            <button type="button" class="btn-close" @click="showEditModal = false" aria-label="Cerrar"></button>
          </div>
          <div class="modal-body p-4">
            <div v-if="selectedAnuncio">
              <form @submit.prevent="updateAnuncio">
                <!-- Información Básica (Solo lectura) -->
                <div class="row mb-4">
                  <div class="col-12">
                    <div class="card">
                      <div class="card-header bg-info text-white">
                        <h6 class="mb-0"><i class="fas fa-info-circle me-2"></i>Información Básica (Solo lectura)</h6>
                      </div>
                      <div class="card-body">
                        <div class="row">
                          <div class="col-md-4">
                            <label class="form-label text-muted"><strong>CVE REQ:</strong></label>
                            <input type="text" class="form-control-plaintext" :value="selectedAnuncio.cvereq" readonly>
                          </div>
                          <div class="col-md-4">
                            <label class="form-label text-muted"><strong>ID Anuncio:</strong></label>
                            <input type="text" class="form-control-plaintext" :value="selectedAnuncio.id_anuncio" readonly>
                          </div>
                          <div class="col-md-4">
                            <label class="form-label text-muted"><strong>Folio:</strong></label>
                            <input type="text" class="form-control-plaintext" :value="selectedAnuncio.folioreq" readonly>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Importes Editables -->
                <div class="row mb-4">
                  <div class="col-12">
                    <div class="card">
                      <div class="card-header bg-success text-white">
                        <h6 class="mb-0"><i class="fas fa-dollar-sign me-2"></i>Importes (Editable)</h6>
                      </div>
                      <div class="card-body">
                        <div class="row">
                          <div class="col-md-6 mb-3">
                            <label for="edit_derechos" class="form-label">
                              <i class="fas fa-coins me-1"></i>Derechos
                            </label>
                            <div class="input-group">
                              <span class="input-group-text">$</span>
                              <input
                                type="number"
                                step="0.01"
                                class="form-control"
                                id="edit_derechos"
                                v-model="editForm.derechos"
                                placeholder="0.00"
                              >
                            </div>
                          </div>
                          <div class="col-md-6 mb-3">
                            <label for="edit_recargos" class="form-label">
                              <i class="fas fa-percentage me-1"></i>Recargos
                            </label>
                            <div class="input-group">
                              <span class="input-group-text">$</span>
                              <input
                                type="number"
                                step="0.01"
                                class="form-control"
                                id="edit_recargos"
                                v-model="editForm.recargos"
                                placeholder="0.00"
                              >
                            </div>
                          </div>
                          <div class="col-md-6 mb-3">
                            <label for="edit_formas" class="form-label">
                              <i class="fas fa-file-invoice me-1"></i>Formas
                            </label>
                            <div class="input-group">
                              <span class="input-group-text">$</span>
                              <input
                                type="number"
                                step="0.01"
                                class="form-control"
                                id="edit_formas"
                                v-model="editForm.formas"
                                placeholder="0.00"
                              >
                            </div>
                          </div>
                          <div class="col-md-6 mb-3">
                            <label for="edit_gastos" class="form-label">
                              <i class="fas fa-receipt me-1"></i>Gastos
                            </label>
                            <div class="input-group">
                              <span class="input-group-text">$</span>
                              <input
                                type="number"
                                step="0.01"
                                class="form-control"
                                id="edit_gastos"
                                v-model="editForm.gastos"
                                placeholder="0.00"
                              >
                            </div>
                          </div>
                          <div class="col-md-6 mb-3">
                            <label for="edit_multa" class="form-label">
                              <i class="fas fa-exclamation-triangle me-1"></i>Multa
                            </label>
                            <div class="input-group">
                              <span class="input-group-text">$</span>
                              <input
                                type="number"
                                step="0.01"
                                class="form-control"
                                id="edit_multa"
                                v-model="editForm.multa"
                                placeholder="0.00"
                              >
                            </div>
                          </div>
                          <div class="col-md-6 mb-3">
                            <label for="edit_gastos_req" class="form-label">
                              <i class="fas fa-clipboard-list me-1"></i>Gastos Requerimiento
                            </label>
                            <div class="input-group">
                              <span class="input-group-text">$</span>
                              <input
                                type="number"
                                step="0.01"
                                class="form-control"
                                id="edit_gastos_req"
                                v-model="editForm.gastos_req"
                                placeholder="0.00"
                              >
                            </div>
                          </div>
                        </div>

                        <!-- Total calculado -->
                        <div class="row">
                          <div class="col-12">
                            <div class="alert alert-success">
                              <h5 class="mb-0">
                                <i class="fas fa-calculator me-2"></i>
                                Total Calculado:
                                <strong>${{ calculateTotal.toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</strong>
                              </h5>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Estado y Fechas -->
                <div class="row mb-4">
                  <div class="col-md-6">
                    <div class="card h-100">
                      <div class="card-header bg-warning text-dark">
                        <h6 class="mb-0"><i class="fas fa-toggle-on me-2"></i>Estado</h6>
                      </div>
                      <div class="card-body">
                        <div class="mb-3">
                          <label for="edit_vigencia" class="form-label">
                            <i class="fas fa-check-circle me-1"></i>Vigencia
                          </label>
                          <select class="form-select" id="edit_vigencia" v-model="editForm.vigencia">
                            <option value="V">Vigente</option>
                            <option value="C">Cancelado</option>
                            <option value="S">Suspendido</option>
                          </select>
                        </div>
                        <div class="mb-3">
                          <label for="edit_cveproceso" class="form-label">
                            <i class="fas fa-cog me-1"></i>Proceso
                          </label>
                          <select class="form-select" id="edit_cveproceso" v-model="editForm.cveproceso">
                            <option value="N">Nuevo</option>
                            <option value="P">En Proceso</option>
                            <option value="C">Completado</option>
                            <option value="X">Cancelado</option>
                          </select>
                        </div>
                        <div class="mb-3">
                          <label for="edit_nodiligenciado" class="form-label">
                            <i class="fas fa-ban me-1"></i>No Diligenciado
                          </label>
                          <select class="form-select" id="edit_nodiligenciado" v-model="editForm.nodiligenciado">
                            <option value="N">No</option>
                            <option value="S">Sí</option>
                          </select>
                        </div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-6">
                    <div class="card h-100">
                      <div class="card-header bg-primary text-white">
                        <h6 class="mb-0"><i class="fas fa-calendar me-2"></i>Fechas</h6>
                      </div>
                      <div class="card-body">
                        <div class="mb-3">
                          <label for="edit_fecentejec" class="form-label">
                            <i class="fas fa-calendar-check me-1"></i>Fecha Entrega Ejecutor
                          </label>
                          <input
                            type="date"
                            class="form-control"
                            id="edit_fecentejec"
                            v-model="editForm.fecentejec"
                          >
                        </div>
                        <div class="mb-3">
                          <label for="edit_feccit" class="form-label">
                            <i class="fas fa-calendar-alt me-1"></i>Fecha Citatorio
                          </label>
                          <input
                            type="date"
                            class="form-control"
                            id="edit_feccit"
                            v-model="editForm.feccit"
                          >
                        </div>
                        <div class="mb-3">
                          <label for="edit_fecprac" class="form-label">
                            <i class="fas fa-calendar-day me-1"></i>Fecha Práctica
                          </label>
                          <input
                            type="date"
                            class="form-control"
                            id="edit_fecprac"
                            v-model="editForm.fecprac"
                          >
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <!-- Observaciones -->
                <div class="row mb-4">
                  <div class="col-12">
                    <div class="card">
                      <div class="card-header bg-secondary text-white">
                        <h6 class="mb-0"><i class="fas fa-comment-alt me-2"></i>Observaciones</h6>
                      </div>
                      <div class="card-body">
                        <textarea
                          class="form-control"
                          rows="4"
                          v-model="editForm.obs"
                          placeholder="Ingrese observaciones..."
                        ></textarea>
                      </div>
                    </div>
                  </div>
                </div>
              </form>
            </div>
          </div>
          <div class="modal-footer bg-light">
            <div class="d-flex justify-content-between w-100">
              <div>
                <button type="button" class="btn btn-outline-danger" @click="confirmDelete">
                  <i class="fas fa-trash me-2"></i>Eliminar
                </button>
              </div>
              <div>
                <button type="button" class="btn btn-secondary me-2" @click="showEditModal = false">
                  <i class="fas fa-times me-2"></i>Cancelar
                </button>
                <button type="button" class="btn btn-success" @click="updateAnuncio" :disabled="updating">
                  <i class="fas fa-save me-2"></i>
                  <span v-if="updating">Guardando...</span>
                  <span v-else>Guardar Cambios</span>
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Crear Nuevo Requerimiento -->
    <div v-if="showCreateModal" class="modal fade show d-block" tabindex="-1" aria-labelledby="modalCrearLabel" aria-hidden="false">
      <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
          <div class="modal-header bg-success text-white">
            <h5 class="modal-title" id="modalCrearLabel">
              <i class="fas fa-plus me-2"></i>
              Crear Nuevo Requerimiento de Anuncio
            </h5>
            <button type="button" class="btn-close btn-close-white" @click="showCreateModal = false" aria-label="Cerrar"></button>
          </div>
          <div class="modal-body p-4">
            <form @submit.prevent="createAnuncioEnhanced">
              <!-- Información Básica -->
              <div class="row mb-4">
                <div class="col-12">
                  <div class="card">
                    <div class="card-header bg-info text-white">
                      <h6 class="mb-0"><i class="fas fa-info-circle me-2"></i>Información Básica</h6>
                    </div>
                    <div class="card-body">
                      <div class="row">
                        <div class="col-md-6 mb-3">
                          <label for="new_folioreq" class="form-label">
                            <strong>Folio Requerimiento <span class="required">*</span></strong>
                          </label>
                          <input
                            type="text"
                            id="new_folioreq"
                            v-model="newForm.folioreq"
                            class="form-control"
                            :class="{ 'input-error': validationErrors.folioreq }"
                            @blur="validateField('folioreq')"
                            placeholder="Ejemplo: FOL-2024-001"
                            maxlength="50"
                          >
                          <div v-if="validationErrors.folioreq" class="field-error">{{ validationErrors.folioreq }}</div>
                        </div>
                        <div class="col-md-6 mb-3">
                          <label for="new_axoreq" class="form-label">
                            <strong>Año Requerimiento <span class="required">*</span></strong>
                          </label>
                          <input
                            type="number"
                            id="new_axoreq"
                            v-model="newForm.axoreq"
                            class="form-control"
                            :class="{ 'input-error': validationErrors.axoreq }"
                            @blur="validateField('axoreq')"
                            min="2020"
                            max="2030"
                            placeholder="2024"
                          >
                          <div v-if="validationErrors.axoreq" class="field-error">{{ validationErrors.axoreq }}</div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-md-6 mb-3">
                          <label for="new_recaud" class="form-label">
                            <strong>Recaudadora <span class="required">*</span></strong>
                          </label>
                          <select
                            id="new_recaud"
                            v-model="newForm.recaud"
                            class="form-select"
                            :class="{ 'input-error': validationErrors.recaud }"
                            @blur="validateField('recaud')"
                          >
                            <option value="">Seleccionar recaudadora</option>
                            <option value="1">GUADALAJARA</option>
                            <option value="2">ZAPOPAN</option>
                            <option value="3">TLAQUEPAQUE</option>
                            <option value="4">TONALÁ</option>
                          </select>
                          <div v-if="validationErrors.recaud" class="field-error">{{ validationErrors.recaud }}</div>
                        </div>
                        <div class="col-md-6 mb-3">
                          <label for="new_tipolic" class="form-label">
                            <strong>Tipo Licencia</strong>
                          </label>
                          <select
                            id="new_tipolic"
                            v-model="newForm.tipolic"
                            class="form-select"
                          >
                            <option value="A">Anuncio</option>
                            <option value="E">Espectacular</option>
                            <option value="T">Temporal</option>
                          </select>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Importes -->
              <div class="row mb-4">
                <div class="col-12">
                  <div class="card">
                    <div class="card-header bg-success text-white">
                      <h6 class="mb-0"><i class="fas fa-dollar-sign me-2"></i>Importes</h6>
                    </div>
                    <div class="card-body">
                      <div class="row">
                        <div class="col-md-6 mb-3">
                          <label for="new_derechos" class="form-label">
                            <strong>Derechos <span class="required">*</span></strong>
                          </label>
                          <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input
                              type="number"
                              id="new_derechos"
                              v-model="newForm.derechos"
                              class="form-control"
                              :class="{ 'input-error': validationErrors.derechos }"
                              @blur="validateField('derechos')"
                              step="0.01"
                              min="0"
                              placeholder="0.00"
                            >
                          </div>
                          <div v-if="validationErrors.derechos" class="field-error">{{ validationErrors.derechos }}</div>
                        </div>
                        <div class="col-md-6 mb-3">
                          <label for="new_recargos" class="form-label">
                            <strong>Recargos</strong>
                          </label>
                          <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input
                              type="number"
                              id="new_recargos"
                              v-model="newForm.recargos"
                              class="form-control"
                              step="0.01"
                              min="0"
                              placeholder="0.00"
                            >
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-md-6 mb-3">
                          <label for="new_formas" class="form-label">
                            <strong>Formas</strong>
                          </label>
                          <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input
                              type="number"
                              id="new_formas"
                              v-model="newForm.formas"
                              class="form-control"
                              step="0.01"
                              min="0"
                              placeholder="0.00"
                            >
                          </div>
                        </div>
                        <div class="col-md-6 mb-3">
                          <label for="new_gastos" class="form-label">
                            <strong>Gastos</strong>
                          </label>
                          <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input
                              type="number"
                              id="new_gastos"
                              v-model="newForm.gastos"
                              class="form-control"
                              step="0.01"
                              min="0"
                              placeholder="0.00"
                            >
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-md-6 mb-3">
                          <label for="new_multa" class="form-label">
                            <strong>Multa</strong>
                          </label>
                          <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input
                              type="number"
                              id="new_multa"
                              v-model="newForm.multa"
                              class="form-control"
                              step="0.01"
                              min="0"
                              placeholder="0.00"
                            >
                          </div>
                        </div>
                        <div class="col-md-6 mb-3">
                          <label for="new_gastos_req" class="form-label">
                            <strong>Gastos Requerimiento</strong>
                          </label>
                          <div class="input-group">
                            <span class="input-group-text">$</span>
                            <input
                              type="number"
                              id="new_gastos_req"
                              v-model="newForm.gastos_req"
                              class="form-control"
                              step="0.01"
                              min="0"
                              placeholder="0.00"
                            >
                          </div>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-12">
                          <div class="alert alert-info">
                            <strong>Total estimado: ${{ calculateNewTotal.toLocaleString('es-MX', { minimumFractionDigits: 2 }) }}</strong>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Estado y Configuración -->
              <div class="row mb-4">
                <div class="col-12">
                  <div class="card">
                    <div class="card-header bg-secondary text-white">
                      <h6 class="mb-0"><i class="fas fa-cogs me-2"></i>Estado y Configuración</h6>
                    </div>
                    <div class="card-body">
                      <div class="row">
                        <div class="col-md-6 mb-3">
                          <label for="new_vigencia" class="form-label">
                            <strong>Vigencia <span class="required">*</span></strong>
                          </label>
                          <select
                            id="new_vigencia"
                            v-model="newForm.vigencia"
                            class="form-select"
                            :class="{ 'input-error': validationErrors.vigencia }"
                            @blur="validateField('vigencia')"
                          >
                            <option value="V">Vigente</option>
                            <option value="N">No Vigente</option>
                            <option value="C">Cancelado</option>
                          </select>
                          <div v-if="validationErrors.vigencia" class="field-error">{{ validationErrors.vigencia }}</div>
                        </div>
                        <div class="col-md-6 mb-3">
                          <label for="new_cveproceso" class="form-label">
                            <strong>Proceso</strong>
                          </label>
                          <select
                            id="new_cveproceso"
                            v-model="newForm.cveproceso"
                            class="form-select"
                          >
                            <option value="N">Nuevo</option>
                            <option value="P">En Proceso</option>
                            <option value="C">Completado</option>
                          </select>
                        </div>
                      </div>
                      <div class="row">
                        <div class="col-12 mb-3">
                          <label for="new_obs" class="form-label">
                            <strong>Observaciones</strong>
                          </label>
                          <textarea
                            id="new_obs"
                            v-model="newForm.obs"
                            class="form-control"
                            rows="3"
                            placeholder="Observaciones adicionales sobre el requerimiento..."
                            maxlength="500"
                          ></textarea>
                          <small class="text-muted">{{ (newForm.obs || '').length }}/500 caracteres</small>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showCreateModal = false">
              <i class="fas fa-times me-2"></i>Cancelar
            </button>
            <button
              type="button"
              class="btn btn-success"
              @click="createAnuncioEnhanced"
              :disabled="creating || Object.keys(validationErrors).length > 0"
            >
              <i class="fas fa-save me-2"></i>
              <span v-if="creating">Creando...</span>
              <span v-else>Crear Requerimiento</span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal backdrop -->
    <div v-if="showViewModal || showCreateModal || showEditModal" class="modal-backdrop show"></div>
    </div>

    <!-- Loading Overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
      </div>
    </div>

    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="toast.type">
      <div class="toast-icon">
        <i v-if="toast.type === 'success'" class="fas fa-check-circle"></i>
        <i v-else-if="toast.type === 'error'" class="fas fa-exclamation-circle"></i>
        <i v-else-if="toast.type === 'warning'" class="fas fa-exclamation-triangle"></i>
        <i v-else class="fas fa-info-circle"></i>
      </div>
      <div class="toast-message">{{ toast.message }}</div>
      <button class="toast-close" @click="hideToast">
        <i class="fas fa-times"></i>
      </button>
    </div>

    <!-- SweetAlert Custom Modal -->
    <div v-if="sweetAlert.show" class="sweet-alert-overlay" @click="sweetAlert.backdrop && cancelSweetAlert()">
      <div class="sweet-alert-container" @click.stop>
        <div class="sweet-alert-icon" :class="sweetAlert.type">
          <i v-if="sweetAlert.type === 'success'" class="fas fa-check"></i>
          <i v-else-if="sweetAlert.type === 'error'" class="fas fa-times"></i>
          <i v-else-if="sweetAlert.type === 'warning'" class="fas fa-exclamation"></i>
          <i v-else-if="sweetAlert.type === 'question'" class="fas fa-question"></i>
          <i v-else class="fas fa-info"></i>
        </div>
        <h2 class="sweet-alert-title">{{ sweetAlert.title }}</h2>
        <p class="sweet-alert-text">{{ sweetAlert.text }}</p>
        <div class="sweet-alert-buttons">
          <button
            v-if="sweetAlert.showCancelButton"
            class="btn btn-secondary"
            @click="cancelSweetAlert"
          >
            {{ sweetAlert.cancelButtonText }}
          </button>
          <button
            class="btn btn-primary"
            @click="confirmSweetAlert"
          >
            {{ sweetAlert.confirmButtonText }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// Importaciones removidas - usando fetch nativo

export default {
  name: 'ConsultaAnunciofrm',
  data() {
    return {
      anuncios: [],
      loading: false,
      loadingMessage: 'Cargando...',
      error: null,
      searchTerm: '',
      currentPage: 1,
      pageSize: 20,
      totalRecords: 0,

      // Modales
      showViewModal: false,
      showCreateModal: false,
      showEditModal: false,
      selectedAnuncio: null,

      // Estadísticas
      stats: {
        vigentes: 0,
        proceso: 0,
        cancelados: 0
      },

      // Formulario de edición
      editForm: {
        cvereq: null,
        derechos: 0,
        recargos: 0,
        formas: 0,
        gastos: 0,
        multa: 0,
        gastos_req: 0,
        vigencia: 'V',
        cveproceso: 'N',
        nodiligenciado: 'N',
        fecentejec: null,
        feccit: null,
        fecprac: null,
        obs: null
      },

      // Formulario de creación
      newForm: {
        folioreq: '',
        axoreq: new Date().getFullYear(),
        recaud: '',
        tipolic: 'A',
        derechos: 0,
        recargos: 0,
        formas: 0,
        gastos: 0,
        multa: 0,
        gastos_req: 0,
        vigencia: 'V',
        cveproceso: 'N',
        obs: ''
      },

      // Estados
      updating: false,
      creating: false,

      // Debounce
      searchTimeout: null,

      // Toast
      toast: {
        show: false,
        type: 'info',
        message: '',
        timeout: null
      },

      // SweetAlert
      sweetAlert: {
        show: false,
        type: 'info',
        title: '',
        text: '',
        showCancelButton: false,
        confirmButtonText: 'Aceptar',
        cancelButtonText: 'Cancelar',
        backdrop: true,
        onConfirm: () => {},
        onCancel: () => {}
      },

      // Validación
      validationErrors: {}
    }
  },

  computed: {
    hasMorePages() {
      return this.currentPage < this.totalPages
    },

    totalPages() {
      return Math.ceil(this.totalRecords / this.pageSize) || 1
    },

    visiblePages() {
      const pages = []
      const totalPages = this.totalPages
      const current = this.currentPage

      if (totalPages <= 7) {
        // Si hay 7 páginas o menos, mostrar todas
        for (let i = 1; i <= totalPages; i++) {
          pages.push(i)
        }
      } else {
        // Lógica para mostrar páginas con puntos suspensivos
        if (current <= 4) {
          // Páginas al inicio
          for (let i = 1; i <= 5; i++) {
            pages.push(i)
          }
          pages.push('...')
          pages.push(totalPages)
        } else if (current >= totalPages - 3) {
          // Páginas al final
          pages.push(1)
          pages.push('...')
          for (let i = totalPages - 4; i <= totalPages; i++) {
            pages.push(i)
          }
        } else {
          // Páginas en el medio
          pages.push(1)
          pages.push('...')
          for (let i = current - 1; i <= current + 1; i++) {
            pages.push(i)
          }
          pages.push('...')
          pages.push(totalPages)
        }
      }

      return pages
    },

    totalImporte() {
      return this.anuncios.reduce((sum, anuncio) => sum + parseFloat(anuncio.total || 0), 0)
    },

    calculateTotal() {
      return parseFloat(this.editForm.derechos || 0) +
             parseFloat(this.editForm.recargos || 0) +
             parseFloat(this.editForm.formas || 0) +
             parseFloat(this.editForm.gastos || 0) +
             parseFloat(this.editForm.multa || 0) +
             parseFloat(this.editForm.gastos_req || 0)
    },

    calculateNewTotal() {
      return parseFloat(this.newForm.derechos || 0) +
             parseFloat(this.newForm.recargos || 0) +
             parseFloat(this.newForm.formas || 0) +
             parseFloat(this.newForm.gastos || 0) +
             parseFloat(this.newForm.multa || 0) +
             parseFloat(this.newForm.gastos_req || 0)
    }
  },

  mounted() {
    this.loadAnuncios()
  },

  methods: {
    async loadAnuncios() {
      this.loading = true
      this.error = null
      this.loadingMessage = 'Cargando requerimientos de anuncios...'

      try {
        const eRequest = {
          Operacion: 'SP_CONSULTA_ANUNCIO_LIST',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_limit', valor: this.pageSize, tipo: 'integer' },
            { nombre: 'p_offset', valor: (this.currentPage - 1) * this.pageSize, tipo: 'integer' },
            { nombre: 'p_search', valor: this.searchTerm || null, tipo: 'string' }
          ]
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse && data.eResponse.success) {
          this.anuncios = data.eResponse.data.result || []
          if (this.anuncios.length > 0) {
            this.totalRecords = parseInt(this.anuncios[0].total_records) || 0
          } else {
            this.totalRecords = 0
          }
          await this.loadEstadisticas()
        } else {
          this.error = data.eResponse?.message || 'Error al cargar los datos'
          // Si no hay datos, generar datos simulados
          this.generarDatosSimulados()
        }
      } catch (error) {
        console.error('Error loading anuncios:', error)
        this.error = 'Error de conexión con el servidor: ' + error.message
        // Generar datos simulados en caso de error
        this.generarDatosSimulados()
      } finally {
        this.loading = false
        this.loadingMessage = 'Cargando...'
      }
    },

    async loadEstadisticas() {
      try {
        const eRequest = {
          Operacion: 'SP_CONSULTA_ANUNCIO_ESTADISTICAS',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: []
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (response.ok) {
          const data = await response.json()
          if (data.eResponse && data.eResponse.success && data.eResponse.data.result.length > 0) {
            const estadisticas = data.eResponse.data.result[0]
            this.stats = {
              vigentes: estadisticas.vigentes || 0,
              proceso: estadisticas.en_proceso || 0,
              cancelados: estadisticas.cancelados || 0
            }
            return
          }
        }
      } catch (error) {
        console.error('Error loading estadísticas:', error)
      }

      // Fallback: calcular estadísticas locales
      this.updateStatsLocal()
    },

    updateStatsLocal() {
      this.stats = {
        vigentes: this.anuncios.filter(a => a.vigencia === 'V').length,
        proceso: this.anuncios.filter(a => a.cveproceso === 'P').length,
        cancelados: this.anuncios.filter(a => a.vigencia === 'C').length
      }
    },

    refreshData() {
      this.currentPage = 1
      this.loadAnuncios()
    },

    debounceSearch() {
      if (this.searchTimeout) {
        clearTimeout(this.searchTimeout)
      }
      this.searchTimeout = setTimeout(() => {
        this.currentPage = 1
        this.loadAnuncios()
      }, 500)
    },

    changePage(page) {
      if (page >= 1 && page <= this.totalPages && page !== this.currentPage) {
        this.currentPage = page
        this.loadAnuncios()
      }
    },

    changePageSize() {
      this.currentPage = 1
      this.loadAnuncios()
    },

    viewAnuncio(anuncio) {
      this.selectedAnuncio = anuncio
      this.showViewModal = true
    },

    editAnuncio(anuncio) {
      this.selectedAnuncio = anuncio
      // Llenar el formulario de edición con los datos del anuncio seleccionado
      this.editForm = {
        cvereq: anuncio.cvereq,
        derechos: parseFloat(anuncio.derechos || 0),
        recargos: parseFloat(anuncio.recargos || 0),
        formas: parseFloat(anuncio.formas || 0),
        gastos: parseFloat(anuncio.gastos || 0),
        multa: parseFloat(anuncio.multa || 0),
        gastos_req: parseFloat(anuncio.gastos_req || 0),
        vigencia: anuncio.vigencia || 'V',
        cveproceso: anuncio.cveproceso || 'N',
        nodiligenciado: anuncio.nodiligenciado || 'N',
        fecentejec: anuncio.fecentejec ? anuncio.fecentejec.split('T')[0] : null,
        feccit: anuncio.feccit ? anuncio.feccit.split('T')[0] : null,
        fecprac: anuncio.fecprac ? anuncio.fecprac.split('T')[0] : null,
        obs: anuncio.obs || ''
      }
      this.showEditModal = true
      this.showViewModal = false
    },

    printDetails() {
      window.print()
    },

    formatDate(date) {
      if (!date) return 'N/A'
      try {
        return new Date(date).toLocaleDateString('es-MX')
      } catch {
        return 'N/A'
      }
    },

    getVigenciaClass(vigencia) {
      switch (vigencia) {
        case 'V': return 'bg-success'
        case 'C': return 'bg-danger'
        case 'S': return 'bg-warning'
        default: return 'bg-secondary'
      }
    },

    getVigenciaText(vigencia) {
      switch (vigencia) {
        case 'V': return 'Vigente'
        case 'C': return 'Cancelado'
        case 'S': return 'Suspendido'
        default: return vigencia || 'N/A'
      }
    },

    getProcesoClass(proceso) {
      switch (proceso) {
        case 'N': return 'bg-primary'
        case 'P': return 'bg-warning'
        case 'C': return 'bg-success'
        case 'X': return 'bg-danger'
        default: return 'bg-secondary'
      }
    },

    getProcesoText(proceso) {
      switch (proceso) {
        case 'N': return 'Nuevo'
        case 'P': return 'En Proceso'
        case 'C': return 'Completado'
        case 'X': return 'Cancelado'
        default: return proceso || 'N/A'
      }
    },

    getRecaudText(recaud) {
      switch (parseInt(recaud)) {
        case 1: return 'GUADALAJARA'
        case 2: return 'ZAPOPAN'
        case 3: return 'TLAQUEPAQUE'
        case 4: return 'TONALÁ'
        default: return recaud || 'N/A'
      }
    },

    async updateAnuncio() {
      this.updating = true
      try {
        // Calcular el total antes de enviar
        const totalCalculado = this.calculateTotal

        const eRequest = {
          Operacion: 'SP_CONSULTA_ANUNCIO_UPDATE',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_cvereq', valor: this.editForm.cvereq, tipo: 'integer' },
            { nombre: 'p_derechos', valor: parseFloat(this.editForm.derechos || 0), tipo: 'decimal' },
            { nombre: 'p_recargos', valor: parseFloat(this.editForm.recargos || 0), tipo: 'decimal' },
            { nombre: 'p_formas', valor: parseFloat(this.editForm.formas || 0), tipo: 'decimal' },
            { nombre: 'p_gastos', valor: parseFloat(this.editForm.gastos || 0), tipo: 'decimal' },
            { nombre: 'p_multa', valor: parseFloat(this.editForm.multa || 0), tipo: 'decimal' },
            { nombre: 'p_gastos_req', valor: parseFloat(this.editForm.gastos_req || 0), tipo: 'decimal' },
            { nombre: 'p_total', valor: totalCalculado, tipo: 'decimal' },
            { nombre: 'p_vigencia', valor: this.editForm.vigencia, tipo: 'string' },
            { nombre: 'p_cveproceso', valor: this.editForm.cveproceso, tipo: 'string' },
            { nombre: 'p_nodiligenciado', valor: this.editForm.nodiligenciado, tipo: 'string' },
            { nombre: 'p_fecentejec', valor: this.editForm.fecentejec, tipo: 'date' },
            { nombre: 'p_feccit', valor: this.editForm.feccit, tipo: 'date' },
            { nombre: 'p_fecprac', valor: this.editForm.fecprac, tipo: 'date' },
            { nombre: 'p_obs', valor: this.editForm.obs, tipo: 'string' }
          ]
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse && data.eResponse.success) {
          // Éxito: cerrar modal y recargar datos
          this.showEditModal = false
          await this.loadAnuncios()
          this.showToast('Requerimiento actualizado exitosamente', 'success')
        } else {
          const errorMsg = data.eResponse?.message || 'Error al actualizar el requerimiento'
          this.showToast(errorMsg, 'error')
        }
      } catch (error) {
        console.error('Error al actualizar:', error)
        this.showToast('Error de conexión: ' + error.message, 'error')
      } finally {
        this.updating = false
      }
    },

    confirmDelete() {
      if (confirm('¿Está seguro de que desea eliminar este requerimiento? Esta acción no se puede deshacer.')) {
        this.deleteAnuncio()
      }
    },

    async deleteAnuncio() {
      try {
        const eRequest = {
          Operacion: 'SP_CONSULTA_ANUNCIO_DELETE',
          Base: 'padron_licencias',
          Tenant: 'guadalajara',
          Parametros: [
            { nombre: 'p_cvereq', valor: this.selectedAnuncio.cvereq, tipo: 'integer' }
          ]
        }

        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()

        if (data.eResponse && data.eResponse.success) {
          this.showToast('Requerimiento eliminado exitosamente', 'success')
          this.showEditModal = false
          await this.loadAnuncios()
        } else {
          const errorMsg = data.eResponse?.message || 'Error al eliminar el requerimiento'
          this.showToast(errorMsg, 'error')
        }
      } catch (error) {
        console.error('Error al eliminar:', error)
        this.showToast('Error de conexión: ' + error.message, 'error')
      }
    },

    // =======================
    // SWEETALERT METHODS
    // =======================
    showAlert(type, title, text, options = {}) {
      this.sweetAlert = {
        show: true,
        type,
        title,
        text,
        showCancelButton: options.showCancelButton || false,
        confirmButtonText: options.confirmButtonText || 'Aceptar',
        cancelButtonText: options.cancelButtonText || 'Cancelar',
        backdrop: options.backdrop !== false,
        onConfirm: options.onConfirm || (() => {}),
        onCancel: options.onCancel || (() => {})
      }
    },

    showSuccess(title, text = '', options = {}) {
      this.showAlert('success', title, text, options)
    },

    showError(title, text = '', options = {}) {
      this.showAlert('error', title, text, options)
    },

    showWarning(title, text = '', options = {}) {
      this.showAlert('warning', title, text, options)
    },

    showInfo(title, text = '', options = {}) {
      this.showAlert('info', title, text, options)
    },

    showConfirm(title, text, onConfirm, onCancel = null) {
      this.showAlert('question', title, text, {
        showCancelButton: true,
        confirmButtonText: 'Sí, confirmar',
        cancelButtonText: 'Cancelar',
        onConfirm,
        onCancel: onCancel || (() => {})
      })
    },

    confirmSweetAlert() {
      const { onConfirm } = this.sweetAlert
      this.sweetAlert.show = false
      if (onConfirm && typeof onConfirm === 'function') {
        onConfirm()
      }
    },

    cancelSweetAlert() {
      const { onCancel } = this.sweetAlert
      this.sweetAlert.show = false
      if (onCancel && typeof onCancel === 'function') {
        onCancel()
      }
    },

    // =======================
    // TOAST METHODS
    // =======================
    showToast(message, type = 'info') {
      if (this.toast.timeout) {
        clearTimeout(this.toast.timeout)
      }

      this.toast = {
        show: true,
        type,
        message,
        timeout: null
      }

      this.toast.timeout = setTimeout(() => {
        this.hideToast()
      }, 4000)
    },

    hideToast() {
      this.toast.show = false
      if (this.toast.timeout) {
        clearTimeout(this.toast.timeout)
        this.toast.timeout = null
      }
    },

    // =======================
    // VALIDATION METHODS
    // =======================
    validateField(fieldName) {
      this.validationErrors = { ...this.validationErrors }
      delete this.validationErrors[fieldName]

      switch (fieldName) {
        case 'derechos':
          if (!this.editForm.derechos || parseFloat(this.editForm.derechos) < 0) {
            this.validationErrors.derechos = 'Los derechos deben ser mayor o igual a 0'
          }
          break
        case 'vigencia':
          if (!this.editForm.vigencia) {
            this.validationErrors.vigencia = 'La vigencia es requerida'
          }
          break
      }
    },

    // =======================
    // ENHANCED METHODS
    // =======================
    async updateAnuncioEnhanced() {
      // Validación antes de enviar
      this.validationErrors = {}
      this.validateField('derechos')
      this.validateField('vigencia')

      if (Object.keys(this.validationErrors).length > 0) {
        this.showError('Error de validación', 'Por favor corrige los errores en el formulario')
        return
      }

      this.showConfirm(
        '¿Confirmar actualización?',
        'Se actualizarán los datos del requerimiento de anuncio',
        async () => {
          try {
            this.updating = true
            await this.updateAnuncio()
            this.showSuccess('¡Actualización exitosa!', 'El requerimiento ha sido actualizado correctamente')
            this.showToast('Requerimiento actualizado exitosamente', 'success')
            this.showEditModal = false
          } catch (error) {
            this.showError('Error al actualizar', error.message)
          }
        }
      )
    },

    confirmDeleteEnhanced(anuncio) {
      this.selectedAnuncio = anuncio
      this.showConfirm(
        '¿Eliminar requerimiento?',
        `Se eliminará permanentemente el requerimiento ${anuncio.cvereq}. Esta acción no se puede deshacer.`,
        async () => {
          try {
            await this.deleteAnuncio()
            this.showSuccess('¡Eliminación exitosa!', 'El requerimiento ha sido eliminado')
            this.showToast('Requerimiento eliminado exitosamente', 'success')
            await this.loadAnuncios()
          } catch (error) {
            this.showError('Error al eliminar', error.message)
          }
        }
      )
    },

    // CREAR NUEVO ANUNCIO
    async createAnuncioEnhanced() {
      // Validación del formulario
      this.validationErrors = {}

      // Validar campos requeridos
      if (!this.newForm.folioreq.trim()) {
        this.validationErrors.folioreq = 'El folio de requerimiento es obligatorio'
      }
      if (!this.newForm.axoreq || this.newForm.axoreq < 2020) {
        this.validationErrors.axoreq = 'El año debe ser mayor a 2020'
      }
      if (!this.newForm.recaud) {
        this.validationErrors.recaud = 'La recaudadora es obligatoria'
      }
      if (!this.newForm.vigencia) {
        this.validationErrors.vigencia = 'La vigencia es obligatoria'
      }
      if (!this.newForm.derechos || parseFloat(this.newForm.derechos) < 0) {
        this.validationErrors.derechos = 'Los derechos deben ser mayor o igual a 0'
      }

      if (Object.keys(this.validationErrors).length > 0) {
        this.showError('Error de validación', 'Por favor corrige los errores en el formulario')
        return
      }

      this.showConfirm(
        '¿Crear nuevo requerimiento?',
        `Se creará un nuevo requerimiento de anuncio con folio ${this.newForm.folioreq}`,
        async () => {
          try {
            this.creating = true
            await this.createAnuncio()
            this.showSuccess('¡Creación exitosa!', 'El nuevo requerimiento ha sido creado correctamente')
            this.showToast('Requerimiento creado exitosamente', 'success')
            this.resetNewForm()
            this.showCreateModal = false
            await this.loadAnuncios()
          } catch (error) {
            this.showError('Error al crear', error.message)
          } finally {
            this.creating = false
          }
        }
      )
    },

    async createAnuncio() {
      const eRequest = {
        Operacion: 'SP_CONSULTA_ANUNCIO_CREATE',
        Base: 'padron_licencias',
        Tenant: 'guadalajara',
        Parametros: [
          { nombre: 'p_folioreq', valor: this.newForm.folioreq, tipo: 'string' },
          { nombre: 'p_axoreq', valor: parseInt(this.newForm.axoreq), tipo: 'integer' },
          { nombre: 'p_recaud', valor: parseInt(this.newForm.recaud), tipo: 'integer' },
          { nombre: 'p_tipolic', valor: this.newForm.tipolic, tipo: 'string' },
          { nombre: 'p_derechos', valor: parseFloat(this.newForm.derechos), tipo: 'decimal' },
          { nombre: 'p_recargos', valor: parseFloat(this.newForm.recargos), tipo: 'decimal' },
          { nombre: 'p_formas', valor: parseFloat(this.newForm.formas), tipo: 'decimal' },
          { nombre: 'p_gastos', valor: parseFloat(this.newForm.gastos), tipo: 'decimal' },
          { nombre: 'p_multa', valor: parseFloat(this.newForm.multa), tipo: 'decimal' },
          { nombre: 'p_gastos_req', valor: parseFloat(this.newForm.gastos_req), tipo: 'decimal' },
          { nombre: 'p_vigencia', valor: this.newForm.vigencia, tipo: 'string' },
          { nombre: 'p_cveproceso', valor: this.newForm.cveproceso, tipo: 'string' },
          { nombre: 'p_obs', valor: this.newForm.obs || null, tipo: 'string' },
          { nombre: 'p_capturista', valor: 'SISTEMA', tipo: 'string' }
        ]
      }

      const response = await fetch('http://localhost:8000/api/generic', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({ eRequest })
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()

      if (!data.eResponse || !data.eResponse.success) {
        throw new Error(data.eResponse?.message || 'Error al crear el requerimiento')
      }

      return data
    },

    resetNewForm() {
      this.newForm = {
        folioreq: '',
        axoreq: new Date().getFullYear(),
        recaud: '',
        tipolic: 'A',
        derechos: 0,
        recargos: 0,
        formas: 0,
        gastos: 0,
        multa: 0,
        gastos_req: 0,
        vigencia: 'V',
        cveproceso: 'N',
        obs: ''
      }
      this.validationErrors = {}
    },

    // Generar datos simulados para demostración
    generarDatosSimulados() {
      console.log('🔄 Generando datos simulados para demostración')

      const anunciosSimulados = []
      const tiposLicencia = ['A', 'E', 'T']
      const recaudadoras = [1, 2, 3, 4]
      const vigencias = ['V', 'C', 'S']
      const procesos = ['N', 'P', 'C', 'X']
      const capturistas = ['ADMIN', 'USUARIO1', 'USUARIO2', 'SISTEMA']

      for (let i = 1; i <= 50; i++) {
        const derechos = Math.random() * 5000 + 1000
        const recargos = Math.random() * 500
        const formas = Math.random() * 200
        const gastos = Math.random() * 300
        const multa = Math.random() * 1000
        const gastos_req = Math.random() * 150

        const anuncio = {
          cvereq: 20240000 + i,
          id_anuncio: `ANU2024-${String(i).padStart(6, '0')}`,
          folioreq: `FOL-2024-${String(i).padStart(3, '0')}`,
          axoreq: 2024,
          recaud: recaudadoras[Math.floor(Math.random() * recaudadoras.length)],
          tipolic: tiposLicencia[Math.floor(Math.random() * tiposLicencia.length)],
          cveproceso: procesos[Math.floor(Math.random() * procesos.length)],
          vigencia: vigencias[Math.floor(Math.random() * vigencias.length)],
          derechos: derechos.toFixed(2),
          recargos: recargos.toFixed(2),
          formas: formas.toFixed(2),
          gastos: gastos.toFixed(2),
          multa: multa.toFixed(2),
          gastos_req: gastos_req.toFixed(2),
          total: (derechos + recargos + formas + gastos + multa + gastos_req).toFixed(2),
          fecemi: new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0],
          fecentejec: Math.random() > 0.5 ? new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0] : null,
          feccit: Math.random() > 0.7 ? new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0] : null,
          fecprac: Math.random() > 0.8 ? new Date(2024, Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1).toISOString().split('T')[0] : null,
          capturista: capturistas[Math.floor(Math.random() * capturistas.length)],
          cveejecut: Math.random() > 0.6 ? `EJE${String(Math.floor(Math.random() * 100) + 1).padStart(3, '0')}` : null,
          nodiligenciado: Math.random() > 0.9 ? 'S' : 'N',
          obs: Math.random() > 0.7 ? `Observación del requerimiento ${i}` : null,
          total_records: 50
        }

        anunciosSimulados.push(anuncio)
      }

      // Aplicar filtros de búsqueda si existen
      let anunciosFiltrados = anunciosSimulados
      if (this.searchTerm && this.searchTerm.trim()) {
        const termino = this.searchTerm.toLowerCase()
        anunciosFiltrados = anunciosSimulados.filter(anuncio =>
          anuncio.cvereq.toString().includes(termino) ||
          anuncio.id_anuncio.toLowerCase().includes(termino) ||
          anuncio.folioreq.toLowerCase().includes(termino) ||
          anuncio.capturista.toLowerCase().includes(termino)
        )
      }

      // Aplicar paginación
      const offset = (this.currentPage - 1) * this.pageSize
      this.anuncios = anunciosFiltrados.slice(offset, offset + this.pageSize)
      this.totalRecords = anunciosFiltrados.length

      // Actualizar estadísticas simuladas
      this.stats = {
        vigentes: anunciosFiltrados.filter(a => a.vigencia === 'V').length,
        proceso: anunciosFiltrados.filter(a => a.cveproceso === 'P').length,
        cancelados: anunciosFiltrados.filter(a => a.vigencia === 'C').length
      }

      console.log(`✅ Generados ${this.anuncios.length} registros simulados de ${anunciosFiltrados.length} total`)
    },

    // Validar campos específicos para el formulario de creación
    validateField(fieldName) {
      // Limpiar error anterior
      this.validationErrors = { ...this.validationErrors }
      delete this.validationErrors[fieldName]

      // Validar según el campo
      if (fieldName === 'folioreq') {
        if (!this.newForm.folioreq.trim()) {
          this.validationErrors.folioreq = 'El folio es requerido'
        }
      } else if (fieldName === 'axoreq') {
        if (!this.newForm.axoreq || this.newForm.axoreq < 2020) {
          this.validationErrors.axoreq = 'El año debe ser mayor a 2020'
        }
      } else if (fieldName === 'recaud') {
        if (!this.newForm.recaud) {
          this.validationErrors.recaud = 'La recaudadora es requerida'
        }
      } else if (fieldName === 'vigencia') {
        if (!this.newForm.vigencia) {
          this.validationErrors.vigencia = 'La vigencia es requerida'
        }
      } else if (fieldName === 'derechos') {
        if (!this.newForm.derechos || parseFloat(this.newForm.derechos) < 0) {
          this.validationErrors.derechos = 'Los derechos deben ser mayor o igual a 0'
        }
      }
    }
  }
}
</script>

<style scoped>
/* Municipal Page Layout */
.municipal-page {
  background: white;
  min-height: 100vh;
  font-family: var(--font-municipal);
}

.consulta-anuncio-container {
  padding: 1.5rem;
  background: white;
  min-height: 100vh;
}

/* Municipal Header */
.municipal-header {
  background: var(--municipal-primary);
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
}

.municipal-title {
  color: white;
  font-size: 1.75rem;
  font-weight: 600;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.municipal-subtitle {
  color: rgba(255, 255, 255, 0.9);
  font-size: 1rem;
  margin-top: 0.5rem;
}

/* Municipal Cards */
.municipal-card {
  background: white;
  border: none;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

/* Municipal Inputs */
.municipal-input {
  border: 2px solid #e2e8f0;
  border-radius: 8px;
  padding: 0.75rem;
  font-size: 1rem;
  transition: all 0.2s ease;
}

.municipal-input:focus {
  border-color: var(--municipal-primary);
  box-shadow: 0 0 0 3px rgba(var(--municipal-primary-rgb), 0.1);
  outline: none;
}

.municipal-input-group {
  background: var(--municipal-primary);
  color: white;
  border: none;
  border-radius: 8px 0 0 8px;
}

/* Municipal Buttons */
.municipal-group-btn {
  display: flex;
  gap: 0.5rem;
}

.municipal-btn-primary {
  background: var(--municipal-primary);
  border-color: var(--municipal-primary);
  color: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.municipal-btn-primary:hover {
  background: var(--municipal-secondary);
  border-color: var(--municipal-secondary);
  transform: translateY(-1px);
}

.municipal-btn-secondary {
  border: 2px solid #6c757d;
  color: #6c757d;
  background: white;
  font-weight: 600;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  transition: all 0.2s ease;
}

.municipal-btn-secondary:hover {
  background: #6c757d;
  color: white;
  transform: translateY(-1px);
}

/* Municipal Table */
.municipal-table-header {
  background: var(--municipal-primary);
  background: linear-gradient(135deg, var(--municipal-primary) 0%, var(--municipal-secondary) 100%);
  color: white;
  border: none;
  padding: 1rem 1.5rem;
}

.municipal-table-header h6 {
  color: white;
  font-size: 1.1rem;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.municipal-table-header-row th {
  background: #f8f9fa;
  color: var(--municipal-primary);
  font-weight: 600;
  font-size: 0.9rem;
  padding: 0.75rem;
  border: none;
  border-bottom: 2px solid #e9ecef;
}

.municipal-table {
  margin: 0;
  background: white;
}

.municipal-table td {
  padding: 0.75rem;
  vertical-align: middle;
  border: none;
  border-bottom: 1px solid #f1f3f4;
  color: #495057;
}

.municipal-table tbody tr:hover {
  background-color: rgba(var(--municipal-primary-rgb), 0.05);
}

.card {
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  border: 1px solid rgba(0, 0, 0, 0.125);
  border-radius: 0.5rem;
  transition: box-shadow 0.15s ease-in-out;
}

.card:hover {
  box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15);
}

.table th {
  font-weight: 600;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  border-bottom: 2px solid #495057;
}

.table td {
  vertical-align: middle;
  font-size: 0.9rem;
}

.table-striped > tbody > tr:nth-of-type(odd) > td {
  background-color: rgba(0, 0, 0, 0.025);
}

.badge {
  font-size: 0.75em;
  font-weight: 500;
  padding: 0.375em 0.75em;
}

.modal.show {
  display: block;
}

.modal-backdrop {
  background-color: rgba(0, 0, 0, 0.5);
}

.btn-group-sm .btn {
  padding: 0.25rem 0.5rem;
  font-size: 0.875rem;
  border-radius: 0.25rem;
}

.btn-group-sm .btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 0.25rem 0.5rem rgba(0, 0, 0, 0.15);
}

.spinner-border {
  width: 2rem;
  height: 2rem;
}

.pagination .page-link {
  border-radius: 0.375rem;
  margin: 0 0.125rem;
  border: 1px solid #dee2e6;
  transition: all 0.15s ease-in-out;
}

.pagination .page-link:hover {
  transform: translateY(-2px);
  box-shadow: 0 0.25rem 0.5rem rgba(0, 0, 0, 0.15);
}

.pagination .page-item.active .page-link {
  background-color: #0d6efd;
  border-color: #0d6efd;
  box-shadow: 0 0.25rem 0.5rem rgba(13, 110, 253, 0.25);
}

.input-group .form-control,
.input-group .form-select {
  border: 1px solid #ced4da;
  transition: border-color 0.15s ease-in-out, box-shadow 0.15s ease-in-out;
}

.input-group .form-control:focus,
.input-group .form-select:focus {
  border-color: #86b7fe;
  box-shadow: 0 0 0 0.25rem rgba(13, 110, 253, 0.25);
}

.card-footer {
  border-top: 1px solid rgba(0, 0, 0, 0.125);
  background-color: rgba(0, 0, 0, 0.03);
}

.text-success {
  color: #198754 !important;
}

.text-primary {
  color: #0d6efd !important;
}

.bg-primary {
  background-color: #0d6efd !important;
}

.bg-success {
  background-color: #198754 !important;
}

.bg-info {
  background-color: #0dcaf0 !important;
}

.bg-warning {
  background-color: #ffc107 !important;
}

.bg-danger {
  background-color: #dc3545 !important;
}

@media (max-width: 768px) {
  .consulta-anuncio-container {
    padding: 1rem;
  }

  .modal-dialog {
    margin: 0.5rem;
  }

  .table-responsive {
    font-size: 0.875rem;
  }

  .btn-group-sm .btn {
    padding: 0.125rem 0.25rem;
    font-size: 0.75rem;
  }
}

@media print {
  .modal-header,
  .modal-footer,
  .btn,
  .pagination {
    display: none !important;
  }

  .modal-dialog {
    max-width: 100% !important;
    margin: 0 !important;
  }

  .modal-content {
    border: none !important;
    box-shadow: none !important;
  }
}
</style>