<template>
  <div class="sistema-convenios">
    <!-- Header Municipal -->
    <div class="municipal-header mb-4">
      <div class="d-flex justify-content-between align-items-center">
        <div>
          <h2 class="municipal-title">
            <i class="fas fa-handshake me-2 text-success"></i>
            Sistema Integral de Convenios
          </h2>
          <p class="municipal-subtitle">
            Gestión completa de convenios de pago, intereses y parcialidades
          </p>
        </div>
        <div class="municipal-stats">
          <div class="row g-2">
            <div class="col-auto">
              <div class="stat-card bg-success">
                <div class="stat-number">{{ estadisticas.convenios_activos || 0 }}</div>
                <div class="stat-label">Activos</div>
              </div>
            </div>
            <div class="col-auto">
              <div class="stat-card bg-warning">
                <div class="stat-number">{{ estadisticas.convenios_vencidos || 0 }}</div>
                <div class="stat-label">Vencidos</div>
              </div>
            </div>
            <div class="col-auto">
              <div class="stat-card bg-primary">
                <div class="stat-number">{{ estadisticas.convenios_liquidados || 0 }}</div>
                <div class="stat-label">Liquidados</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Navegación por Tabs -->
    <div class="municipal-tabs mb-4">
      <ul class="nav nav-pills nav-justified" role="tablist">
        <li class="nav-item">
          <button
            class="nav-link"
            :class="{ active: activeTab === 'convenios' }"
            @click="activeTab = 'convenios'"
            type="button"
          >
            <i class="fas fa-file-contract me-2"></i>
            Convenios
          </button>
        </li>
        <li class="nav-item">
          <button
            class="nav-link"
            :class="{ active: activeTab === 'parcialidades' }"
            @click="activeTab = 'parcialidades'"
            type="button"
          >
            <i class="fas fa-list-ol me-2"></i>
            Parcialidades
          </button>
        </li>
        <li class="nav-item">
          <button
            class="nav-link"
            :class="{ active: activeTab === 'pagos' }"
            @click="activeTab = 'pagos'"
            type="button"
          >
            <i class="fas fa-credit-card me-2"></i>
            Pagos
          </button>
        </li>
        <li class="nav-item">
          <button
            class="nav-link"
            :class="{ active: activeTab === 'estadisticas' }"
            @click="activeTab = 'estadisticas'"
            type="button"
          >
            <i class="fas fa-chart-bar me-2"></i>
            Estadísticas
          </button>
        </li>
      </ul>
    </div>

    <!-- Tab Content -->
    <div class="tab-content">
      <!-- Tab Convenios -->
      <div v-show="activeTab === 'convenios'" class="tab-pane fade show active">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <div class="d-flex justify-content-between align-items-center">
              <h5 class="mb-0">
                <i class="fas fa-file-contract me-2"></i>
                Gestión de Convenios
              </h5>
              <button class="btn btn-municipal-primary" @click="abrirModalConvenio()">
                <i class="fas fa-plus me-2"></i>Nuevo Convenio
              </button>
            </div>
          </div>

          <!-- Controles de Filtro -->
          <div class="municipal-controls">
            <div class="row g-3">
              <div class="col-md-3">
                <label class="form-label">Estado:</label>
                <select class="form-select" v-model="filtros.estatus" @change="cargarConvenios">
                  <option value="TODOS">Todos los estados</option>
                  <option value="ACTIVO">Activos</option>
                  <option value="LIQUIDADO">Liquidados</option>
                  <option value="VENCIDO">Vencidos</option>
                </select>
              </div>
              <div class="col-md-3">
                <label class="form-label">Tipo:</label>
                <select class="form-select" v-model="filtros.tipo_convenio" @change="cargarConvenios">
                  <option value="TODOS">Todos los tipos</option>
                  <option value="LICENCIA">Licencias</option>
                  <option value="MULTA">Multas</option>
                  <option value="OTROS">Otros</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Buscar:</label>
                <input
                  type="text"
                  class="form-control"
                  placeholder="Número de convenio, contribuyente, RFC..."
                  v-model="filtros.busqueda"
                  @input="buscarConvenios"
                >
              </div>
              <div class="col-md-2">
                <label class="form-label">&nbsp;</label>
                <div class="d-grid">
                  <button class="btn btn-outline-municipal" @click="exportarExcel">
                    <i class="fas fa-file-excel me-1"></i>Exportar
                  </button>
                </div>
              </div>
            </div>
          </div>

          <!-- Tabla de Convenios -->
          <div class="table-responsive">
            <table class="table municipal-table">
              <thead>
                <tr>
                  <th>Folio</th>
                  <th>Contribuyente</th>
                  <th>RFC</th>
                  <th>Tipo</th>
                  <th>Monto Total</th>
                  <th>Pagado</th>
                  <th>Pendiente</th>
                  <th>Parcialidades</th>
                  <th>Estado</th>
                  <th>Vencimiento</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="cargandoConvenios">
                  <td colspan="11" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Cargando...</span>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="convenios.length === 0">
                  <td colspan="11" class="text-center py-4 text-muted">
                    <i class="fas fa-inbox fa-2x mb-2"></i>
                    <br>No se encontraron convenios
                  </td>
                </tr>
                <tr v-else v-for="convenio in convenios" :key="convenio.id_convenio">
                  <td>
                    <strong class="text-primary">{{ convenio.numero_convenio }}</strong>
                  </td>
                  <td>{{ convenio.nombre_contribuyente }}</td>
                  <td>{{ convenio.rfc }}</td>
                  <td>
                    <span class="badge" :class="getBadgeClassTipo(convenio.tipo_convenio)">
                      {{ convenio.tipo_convenio }}
                    </span>
                  </td>
                  <td class="text-end">
                    <strong>${{ formatCurrency(convenio.monto_total) }}</strong>
                  </td>
                  <td class="text-end text-success">
                    ${{ formatCurrency(convenio.monto_pagado) }}
                  </td>
                  <td class="text-end text-danger">
                    ${{ formatCurrency(convenio.monto_pendiente) }}
                  </td>
                  <td class="text-center">
                    <span class="badge bg-info">
                      {{ convenio.parcialidades_pagadas }}/{{ convenio.numero_parcialidades }}
                    </span>
                    <div class="progress mt-1" style="height: 4px;">
                      <div
                        class="progress-bar bg-success"
                        :style="{ width: convenio.porcentaje_avance + '%' }"
                      ></div>
                    </div>
                  </td>
                  <td>
                    <span class="badge" :class="getBadgeClassEstatus(convenio.estatus, convenio.dias_vencido)">
                      {{ getEstatusDisplay(convenio.estatus, convenio.dias_vencido) }}
                    </span>
                  </td>
                  <td>
                    <small>{{ formatDate(convenio.fecha_vencimiento) }}</small>
                  </td>
                  <td>
                    <div class="btn-group" role="group">
                      <button
                        class="btn btn-sm btn-outline-info"
                        @click="verDetalleConvenio(convenio)"
                        title="Ver detalle"
                      >
                        <i class="fas fa-eye"></i>
                      </button>
                      <button
                        class="btn btn-sm btn-outline-success"
                        @click="verParcialidades(convenio)"
                        title="Ver parcialidades"
                        :disabled="convenio.estatus === 'LIQUIDADO'"
                      >
                        <i class="fas fa-list"></i>
                      </button>
                      <button
                        class="btn btn-sm btn-outline-primary"
                        @click="registrarPago(convenio)"
                        title="Registrar pago"
                        :disabled="convenio.estatus === 'LIQUIDADO'"
                      >
                        <i class="fas fa-dollar-sign"></i>
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div class="municipal-pagination" v-if="totalRegistros > 0">
            <div class="d-flex justify-content-between align-items-center">
              <div class="pagination-info">
                Mostrando {{ (currentPage - 1) * itemsPerPage + 1 }} -
                {{ Math.min(currentPage * itemsPerPage, totalRegistros) }}
                de {{ totalRegistros }} registros
              </div>
              <nav>
                <ul class="pagination pagination-sm mb-0">
                  <li class="page-item" :class="{ disabled: currentPage === 1 }">
                    <button class="page-link" @click="cambiarPagina(currentPage - 1)">
                      <i class="fas fa-chevron-left"></i>
                    </button>
                  </li>
                  <li
                    class="page-item"
                    v-for="page in getVisiblePages()"
                    :key="page"
                    :class="{ active: page === currentPage }"
                  >
                    <button class="page-link" @click="cambiarPagina(page)">{{ page }}</button>
                  </li>
                  <li class="page-item" :class="{ disabled: currentPage === totalPages }">
                    <button class="page-link" @click="cambiarPagina(currentPage + 1)">
                      <i class="fas fa-chevron-right"></i>
                    </button>
                  </li>
                </ul>
              </nav>
            </div>
          </div>
        </div>
      </div>

      <!-- Tab Parcialidades -->
      <div v-show="activeTab === 'parcialidades'" class="tab-pane fade">
        <div class="municipal-card" v-if="convenioSeleccionado">
          <div class="municipal-card-header">
            <h5 class="mb-0">
              <i class="fas fa-list-ol me-2"></i>
              Parcialidades del Convenio: {{ convenioSeleccionado.numero_convenio }}
            </h5>
          </div>

          <!-- Info del Convenio -->
          <div class="alert alert-info">
            <div class="row">
              <div class="col-md-6">
                <strong>Contribuyente:</strong> {{ convenioSeleccionado.nombre_contribuyente }}<br>
                <strong>RFC:</strong> {{ convenioSeleccionado.rfc }}
              </div>
              <div class="col-md-6">
                <strong>Monto Total:</strong> ${{ formatCurrency(convenioSeleccionado.monto_total) }}<br>
                <strong>Progreso:</strong> {{ convenioSeleccionado.parcialidades_pagadas }}/{{ convenioSeleccionado.numero_parcialidades }}
                ({{ convenioSeleccionado.porcentaje_avance }}%)
              </div>
            </div>
          </div>

          <!-- Tabla de Parcialidades -->
          <div class="table-responsive">
            <table class="table municipal-table">
              <thead>
                <tr>
                  <th>No.</th>
                  <th>Fecha Vencimiento</th>
                  <th>Monto</th>
                  <th>Interés</th>
                  <th>Total</th>
                  <th>Estado</th>
                  <th>Fecha Pago</th>
                  <th>Recibo</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr
                  v-for="parcialidad in parcialidades"
                  :key="parcialidad.numero_parcialidad"
                  :class="getRowClassParcialidad(parcialidad)"
                >
                  <td><strong>{{ parcialidad.numero_parcialidad }}</strong></td>
                  <td>{{ formatDate(parcialidad.fecha_vencimiento) }}</td>
                  <td class="text-end">${{ formatCurrency(parcialidad.monto_pago) }}</td>
                  <td class="text-end text-warning">
                    ${{ formatCurrency(parcialidad.interes_generado || 0) }}
                  </td>
                  <td class="text-end">
                    <strong>${{ formatCurrency((parcialidad.monto_pago || 0) + (parcialidad.interes_generado || 0)) }}</strong>
                  </td>
                  <td>
                    <span class="badge" :class="getBadgeClassParcialidad(parcialidad.estatus)">
                      {{ parcialidad.estatus }}
                    </span>
                  </td>
                  <td>
                    {{ parcialidad.fecha_pago ? formatDate(parcialidad.fecha_pago) : '-' }}
                  </td>
                  <td>
                    {{ parcialidad.recibo_pago || '-' }}
                  </td>
                  <td>
                    <button
                      v-if="parcialidad.estatus === 'PENDIENTE'"
                      class="btn btn-sm btn-success"
                      @click="pagarParcialidad(parcialidad)"
                      title="Registrar pago"
                    >
                      <i class="fas fa-dollar-sign"></i>
                    </button>
                    <button
                      v-else-if="parcialidad.recibo_pago"
                      class="btn btn-sm btn-info"
                      @click="verRecibo(parcialidad.recibo_pago)"
                      title="Ver recibo"
                    >
                      <i class="fas fa-receipt"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div v-else class="municipal-card">
          <div class="text-center py-5 text-muted">
            <i class="fas fa-info-circle fa-3x mb-3"></i>
            <h5>Selecciona un convenio</h5>
            <p>Ve a la pestaña de Convenios y selecciona uno para ver sus parcialidades</p>
          </div>
        </div>
      </div>

      <!-- Tab Pagos -->
      <div v-show="activeTab === 'pagos'" class="tab-pane fade">
        <div class="municipal-card">
          <div class="municipal-card-header">
            <h5 class="mb-0">
              <i class="fas fa-credit-card me-2"></i>
              Historial de Pagos
            </h5>
          </div>

          <div class="table-responsive">
            <table class="table municipal-table">
              <thead>
                <tr>
                  <th>Recibo</th>
                  <th>Fecha</th>
                  <th>Convenio</th>
                  <th>Contribuyente</th>
                  <th>Parcialidad</th>
                  <th>Monto</th>
                  <th>Forma Pago</th>
                  <th>Cajero</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="cargandoPagos">
                  <td colspan="9" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Cargando...</span>
                    </div>
                  </td>
                </tr>
                <tr v-else-if="pagos.length === 0">
                  <td colspan="9" class="text-center py-4 text-muted">
                    <i class="fas fa-inbox fa-2x mb-2"></i>
                    <br>No se encontraron pagos
                  </td>
                </tr>
                <tr v-else v-for="pago in pagos" :key="pago.recibo_pago">
                  <td><strong class="text-primary">{{ pago.recibo_pago }}</strong></td>
                  <td>{{ formatDate(pago.fecha_pago) }}</td>
                  <td>{{ pago.numero_convenio }}</td>
                  <td>{{ pago.nombre_contribuyente }}</td>
                  <td class="text-center">
                    <span class="badge bg-info">{{ pago.numero_parcialidad }}</span>
                  </td>
                  <td class="text-end text-success">
                    <strong>${{ formatCurrency(pago.monto_pago) }}</strong>
                  </td>
                  <td>
                    <span class="badge" :class="getBadgeClassFormaPago(pago.forma_pago)">
                      {{ pago.forma_pago }}
                    </span>
                  </td>
                  <td>{{ pago.usuario_cajero }}</td>
                  <td>
                    <button
                      class="btn btn-sm btn-outline-info me-1"
                      @click="verRecibo(pago.recibo_pago)"
                      title="Ver recibo"
                    >
                      <i class="fas fa-print"></i>
                    </button>
                    <button
                      class="btn btn-sm btn-outline-secondary"
                      @click="enviarEmailRecibo(pago.recibo_pago)"
                      title="Enviar por email"
                    >
                      <i class="fas fa-envelope"></i>
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Tab Estadísticas -->
      <div v-show="activeTab === 'estadisticas'" class="tab-pane fade">
        <div class="row g-4">
          <!-- Métricas Generales -->
          <div class="col-md-3">
            <div class="municipal-card stat-card">
              <div class="stat-icon bg-success">
                <i class="fas fa-handshake"></i>
              </div>
              <div class="stat-content">
                <h3>{{ estadisticas.total_convenios || 0 }}</h3>
                <p>Total Convenios</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="municipal-card stat-card">
              <div class="stat-icon bg-primary">
                <i class="fas fa-dollar-sign"></i>
              </div>
              <div class="stat-content">
                <h3>${{ formatCurrency(estadisticas.monto_total_convenios || 0) }}</h3>
                <p>Monto Total</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="municipal-card stat-card">
              <div class="stat-icon bg-warning">
                <i class="fas fa-percentage"></i>
              </div>
              <div class="stat-content">
                <h3>{{ estadisticas.tasa_cumplimiento || 0 }}%</h3>
                <p>Tasa Cumplimiento</p>
              </div>
            </div>
          </div>
          <div class="col-md-3">
            <div class="municipal-card stat-card">
              <div class="stat-icon bg-info">
                <i class="fas fa-chart-line"></i>
              </div>
              <div class="stat-content">
                <h3>${{ formatCurrency(estadisticas.interes_total_generado || 0) }}</h3>
                <p>Intereses Generados</p>
              </div>
            </div>
          </div>

          <!-- Gráficos y tablas adicionales -->
          <div class="col-12">
            <div class="municipal-card">
              <div class="municipal-card-header">
                <h5 class="mb-0">
                  <i class="fas fa-chart-pie me-2"></i>
                  Distribución por Tipo de Convenio
                </h5>
              </div>
              <div class="card-body">
                <div class="row">
                  <div class="col-md-4">
                    <div class="progress-item">
                      <div class="d-flex justify-content-between">
                        <span>Licencias</span>
                        <span>{{ estadisticas.convenios_licencias || 0 }}</span>
                      </div>
                      <div class="progress">
                        <div class="progress-bar bg-success" :style="{ width: getPercentaje(estadisticas.convenios_licencias, estadisticas.total_convenios) + '%' }"></div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="progress-item">
                      <div class="d-flex justify-content-between">
                        <span>Multas</span>
                        <span>{{ estadisticas.convenios_multas || 0 }}</span>
                      </div>
                      <div class="progress">
                        <div class="progress-bar bg-warning" :style="{ width: getPercentaje(estadisticas.convenios_multas, estadisticas.total_convenios) + '%' }"></div>
                      </div>
                    </div>
                  </div>
                  <div class="col-md-4">
                    <div class="progress-item">
                      <div class="d-flex justify-content-between">
                        <span>Otros</span>
                        <span>{{ estadisticas.convenios_otros || 0 }}</span>
                      </div>
                      <div class="progress">
                        <div class="progress-bar bg-info" :style="{ width: getPercentaje(estadisticas.convenios_otros, estadisticas.total_convenios) + '%' }"></div>
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

    <!-- Modal Nuevo Convenio -->
    <div class="modal fade" id="modalConvenio" tabindex="-1">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-plus me-2"></i>
              {{ modoEdicion ? 'Editar Convenio' : 'Nuevo Convenio' }}
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body">
            <form @submit.prevent="guardarConvenio">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Número de Licencia *</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="formConvenio.numero_licencia"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Tipo de Convenio *</label>
                  <select class="form-select" v-model="formConvenio.tipo_convenio" required>
                    <option value="">Seleccionar...</option>
                    <option value="LICENCIA">Licencia</option>
                    <option value="MULTA">Multa</option>
                    <option value="OTROS">Otros</option>
                  </select>
                </div>
                <div class="col-md-8">
                  <label class="form-label">Nombre del Contribuyente *</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="formConvenio.nombre_contribuyente"
                    required
                  >
                </div>
                <div class="col-md-4">
                  <label class="form-label">RFC *</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="formConvenio.rfc"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">CURP</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="formConvenio.curp"
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Teléfono</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="formConvenio.telefono"
                  >
                </div>
                <div class="col-12">
                  <label class="form-label">Domicilio</label>
                  <textarea
                    class="form-control"
                    rows="2"
                    v-model="formConvenio.domicilio"
                  ></textarea>
                </div>
                <div class="col-12">
                  <label class="form-label">Concepto del Adeudo *</label>
                  <textarea
                    class="form-control"
                    rows="2"
                    v-model="formConvenio.concepto_adeudo"
                    required
                  ></textarea>
                </div>
                <div class="col-md-4">
                  <label class="form-label">Monto Original *</label>
                  <input
                    type="number"
                    class="form-control"
                    step="0.01"
                    v-model="formConvenio.monto_original"
                    required
                  >
                </div>
                <div class="col-md-4">
                  <label class="form-label">Número de Parcialidades *</label>
                  <select class="form-select" v-model="formConvenio.numero_parcialidades" required>
                    <option value="">Seleccionar...</option>
                    <option value="3">3 meses</option>
                    <option value="6">6 meses</option>
                    <option value="9">9 meses</option>
                    <option value="12">12 meses</option>
                    <option value="18">18 meses</option>
                    <option value="24">24 meses</option>
                  </select>
                </div>
                <div class="col-md-4">
                  <label class="form-label">Tasa de Interés (%)</label>
                  <input
                    type="number"
                    class="form-control"
                    step="0.1"
                    v-model="formConvenio.tasa_interes"
                    placeholder="0.0"
                  >
                </div>
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    class="form-control"
                    rows="3"
                    v-model="formConvenio.observaciones"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
              Cancelar
            </button>
            <button type="button" class="btn btn-municipal-primary" @click="guardarConvenio" :disabled="guardandoConvenio">
              <span v-if="guardandoConvenio" class="spinner-border spinner-border-sm me-2"></span>
              {{ modoEdicion ? 'Actualizar' : 'Crear' }} Convenio
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Pago de Parcialidad -->
    <div class="modal fade" id="modalPago" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header municipal-modal-header">
            <h5 class="modal-title">
              <i class="fas fa-dollar-sign me-2"></i>
              Registrar Pago de Parcialidad
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body" v-if="parcialidadPago">
            <div class="alert alert-info">
              <strong>Convenio:</strong> {{ parcialidadPago.numero_convenio }}<br>
              <strong>Parcialidad:</strong> {{ parcialidadPago.numero_parcialidad }}<br>
              <strong>Monto:</strong> ${{ formatCurrency(parcialidadPago.monto_pago) }}
            </div>
            <form @submit.prevent="procesarPago">
              <div class="row g-3">
                <div class="col-md-6">
                  <label class="form-label">Monto a Pagar *</label>
                  <input
                    type="number"
                    class="form-control"
                    step="0.01"
                    v-model="formPago.monto_pagado"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Fecha de Pago *</label>
                  <input
                    type="date"
                    class="form-control"
                    v-model="formPago.fecha_pago"
                    required
                  >
                </div>
                <div class="col-md-6">
                  <label class="form-label">Forma de Pago *</label>
                  <select class="form-select" v-model="formPago.forma_pago" required>
                    <option value="">Seleccionar...</option>
                    <option value="EFECTIVO">Efectivo</option>
                    <option value="TRANSFERENCIA">Transferencia</option>
                    <option value="CHEQUE">Cheque</option>
                    <option value="TARJETA">Tarjeta</option>
                  </select>
                </div>
                <div class="col-md-6">
                  <label class="form-label">Referencia</label>
                  <input
                    type="text"
                    class="form-control"
                    v-model="formPago.referencia_pago"
                    placeholder="Número de referencia"
                  >
                </div>
                <div class="col-12">
                  <label class="form-label">Observaciones</label>
                  <textarea
                    class="form-control"
                    rows="2"
                    v-model="formPago.observaciones_pago"
                  ></textarea>
                </div>
              </div>
            </form>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">
              Cancelar
            </button>
            <button type="button" class="btn btn-success" @click="procesarPago" :disabled="procesandoPago">
              <span v-if="procesandoPago" class="spinner-border spinner-border-sm me-2"></span>
              Registrar Pago
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'SistemaConvenios',
  data() {
    return {
      activeTab: 'convenios',

      // Estados de carga
      cargandoConvenios: false,
      cargandoPagos: false,
      guardandoConvenio: false,
      procesandoPago: false,

      // Datos
      convenios: [],
      parcialidades: [],
      pagos: [],
      estadisticas: {},
      convenioSeleccionado: null,
      parcialidadPago: null,

      // Filtros y búsqueda
      filtros: {
        estatus: 'TODOS',
        tipo_convenio: 'TODOS',
        busqueda: ''
      },

      // Paginación
      currentPage: 1,
      itemsPerPage: 20,
      totalRegistros: 0,

      // Formularios
      modoEdicion: false,
      formConvenio: {
        numero_licencia: '',
        nombre_contribuyente: '',
        rfc: '',
        curp: '',
        domicilio: '',
        telefono: '',
        email: '',
        tipo_convenio: '',
        concepto_adeudo: '',
        monto_original: '',
        numero_parcialidades: '',
        tasa_interes: 0,
        observaciones: ''
      },

      formPago: {
        monto_pagado: '',
        fecha_pago: new Date().toISOString().split('T')[0],
        forma_pago: '',
        referencia_pago: '',
        observaciones_pago: ''
      }
    }
  },

  computed: {
    totalPages() {
      return Math.ceil(this.totalRegistros / this.itemsPerPage)
    }
  },

  mounted() {
    this.cargarConvenios()
    this.cargarEstadisticas()
  },

  methods: {
    async cargarConvenios() {
      this.cargandoConvenios = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_sistema_convenios_list',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_limite', valor: this.itemsPerPage },
                { nombre: 'p_offset', valor: (this.currentPage - 1) * this.itemsPerPage },
                { nombre: 'p_filtro', valor: this.filtros.busqueda },
                { nombre: 'p_estatus', valor: this.filtros.estatus },
                { nombre: 'p_tipo_convenio', valor: this.filtros.tipo_convenio }
              ]
            }
          })
        })
        const data = await response.json()

        if (data.success && data.data) {
          this.convenios = data.data
          if (this.convenios.length > 0) {
            this.totalRegistros = this.convenios[0].total_registros
          }
        }
      } catch (error) {
        console.error('Error al cargar convenios:', error)
        this.$toast.error('Error al cargar convenios')
      } finally {
        this.cargandoConvenios = false
      }
    },

    async cargarEstadisticas() {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_sistema_convenios_estadisticas',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: []
            }
          })
        })
        const data = await response.json()

        if (data.success && data.data && data.data.length > 0) {
          this.estadisticas = data.data[0]
        }
      } catch (error) {
        console.error('Error al cargar estadísticas:', error)
      }
    },

    async cargarParcialidades(idConvenio) {
      try {
        // Simulación - en producción usar SP específico para parcialidades
        this.parcialidades = [
          {
            numero_parcialidad: 1,
            fecha_vencimiento: '2025-01-15',
            monto_pago: 10000,
            interes_generado: 150,
            estatus: 'PAGADO',
            fecha_pago: '2025-01-14',
            recibo_pago: 'REC-001234'
          },
          {
            numero_parcialidad: 2,
            fecha_vencimiento: '2025-02-15',
            monto_pago: 10000,
            interes_generado: 200,
            estatus: 'VENCIDO',
            fecha_pago: null,
            recibo_pago: null
          }
        ]
      } catch (error) {
        console.error('Error al cargar parcialidades:', error)
      }
    },

    async cargarPagos() {
      this.cargandoPagos = true
      try {
        // Simulación - en producción usar SP específico para pagos
        this.pagos = [
          {
            recibo_pago: 'REC-001234',
            fecha_pago: '2025-01-14',
            numero_convenio: 'CONV-2025-001',
            nombre_contribuyente: 'COMERCIAL LÓPEZ SA',
            numero_parcialidad: 1,
            monto_pago: 10150,
            forma_pago: 'EFECTIVO',
            usuario_cajero: 'María González'
          }
        ]
      } catch (error) {
        console.error('Error al cargar pagos:', error)
      } finally {
        this.cargandoPagos = false
      }
    },

    buscarConvenios() {
      clearTimeout(this.searchTimeout)
      this.searchTimeout = setTimeout(() => {
        this.currentPage = 1
        this.cargarConvenios()
      }, 500)
    },

    abrirModalConvenio(convenio = null) {
      this.modoEdicion = !!convenio
      if (convenio) {
        this.formConvenio = { ...convenio }
      } else {
        this.formConvenio = {
          numero_licencia: '',
          nombre_contribuyente: '',
          rfc: '',
          curp: '',
          domicilio: '',
          telefono: '',
          email: '',
          tipo_convenio: '',
          concepto_adeudo: '',
          monto_original: '',
          numero_parcialidades: '',
          tasa_interes: 0,
          observaciones: ''
        }
      }

      const modal = new bootstrap.Modal(document.getElementById('modalConvenio'))
      modal.show()
    },

    async guardarConvenio() {
      this.guardandoConvenio = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_sistema_convenios_create',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_numero_licencia', valor: this.formConvenio.numero_licencia },
                { nombre: 'p_nombre_contribuyente', valor: this.formConvenio.nombre_contribuyente },
                { nombre: 'p_rfc', valor: this.formConvenio.rfc },
                { nombre: 'p_curp', valor: this.formConvenio.curp },
                { nombre: 'p_domicilio', valor: this.formConvenio.domicilio },
                { nombre: 'p_telefono', valor: this.formConvenio.telefono },
                { nombre: 'p_email', valor: this.formConvenio.email },
                { nombre: 'p_tipo_convenio', valor: this.formConvenio.tipo_convenio },
                { nombre: 'p_concepto_adeudo', valor: this.formConvenio.concepto_adeudo },
                { nombre: 'p_monto_original', valor: parseFloat(this.formConvenio.monto_original) },
                { nombre: 'p_numero_parcialidades', valor: parseInt(this.formConvenio.numero_parcialidades) },
                { nombre: 'p_tasa_interes', valor: parseFloat(this.formConvenio.tasa_interes) || 0 },
                { nombre: 'p_observaciones', valor: this.formConvenio.observaciones },
                { nombre: 'p_usuario_responsable', valor: 'admin' }
              ]
            }
          })
        })
        const data = await response.json()

        if (data.success) {
          this.$toast.success('Convenio creado exitosamente')
          this.cargarConvenios()
          this.cargarEstadisticas()

          const modal = bootstrap.Modal.getInstance(document.getElementById('modalConvenio'))
          modal.hide()
        } else {
          this.$toast.error(data.message || 'Error al crear convenio')
        }
      } catch (error) {
        console.error('Error al guardar convenio:', error)
        this.$toast.error('Error al guardar convenio')
      } finally {
        this.guardandoConvenio = false
      }
    },

    verDetalleConvenio(convenio) {
      this.convenioSeleccionado = convenio
      this.cargarParcialidades(convenio.id_convenio)
      this.activeTab = 'parcialidades'
    },

    verParcialidades(convenio) {
      this.convenioSeleccionado = convenio
      this.cargarParcialidades(convenio.id_convenio)
      this.activeTab = 'parcialidades'
    },

    registrarPago(convenio) {
      // Buscar primera parcialidad pendiente
      this.parcialidadPago = {
        id_convenio: convenio.id_convenio,
        numero_convenio: convenio.numero_convenio,
        numero_parcialidad: 1, // Simular primera parcialidad pendiente
        monto_pago: 10000 // Simular monto
      }

      this.formPago.monto_pagado = this.parcialidadPago.monto_pago

      const modal = new bootstrap.Modal(document.getElementById('modalPago'))
      modal.show()
    },

    pagarParcialidad(parcialidad) {
      this.parcialidadPago = parcialidad
      this.formPago.monto_pagado = parcialidad.monto_pago

      const modal = new bootstrap.Modal(document.getElementById('modalPago'))
      modal.show()
    },

    async procesarPago() {
      this.procesandoPago = true
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'sp_sistema_convenios_pago_parcialidad',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_id_convenio', valor: this.parcialidadPago.id_convenio },
                { nombre: 'p_numero_parcialidad', valor: this.parcialidadPago.numero_parcialidad },
                { nombre: 'p_monto_pagado', valor: parseFloat(this.formPago.monto_pagado) },
                { nombre: 'p_fecha_pago', valor: this.formPago.fecha_pago },
                { nombre: 'p_forma_pago', valor: this.formPago.forma_pago },
                { nombre: 'p_referencia_pago', valor: this.formPago.referencia_pago },
                { nombre: 'p_observaciones_pago', valor: this.formPago.observaciones_pago },
                { nombre: 'p_usuario_cajero', valor: 'admin' }
              ]
            }
          })
        })
        const data = await response.json()

        if (data.success) {
          this.$toast.success('Pago registrado exitosamente')
          this.cargarConvenios()
          this.cargarParcialidades(this.parcialidadPago.id_convenio)
          this.cargarEstadisticas()

          const modal = bootstrap.Modal.getInstance(document.getElementById('modalPago'))
          modal.hide()
        } else {
          this.$toast.error(data.message || 'Error al registrar pago')
        }
      } catch (error) {
        console.error('Error al procesar pago:', error)
        this.$toast.error('Error al procesar pago')
      } finally {
        this.procesandoPago = false
      }
    },

    cambiarPagina(page) {
      if (page >= 1 && page <= this.totalPages) {
        this.currentPage = page
        this.cargarConvenios()
      }
    },

    getVisiblePages() {
      const pages = []
      const start = Math.max(1, this.currentPage - 2)
      const end = Math.min(this.totalPages, this.currentPage + 2)

      for (let i = start; i <= end; i++) {
        pages.push(i)
      }
      return pages
    },

    // Métodos de formato y utilidades
    formatCurrency(value) {
      if (!value) return '0.00'
      return parseFloat(value).toLocaleString('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      })
    },

    formatDate(date) {
      if (!date) return '-'
      return new Date(date).toLocaleDateString('es-MX')
    },

    getBadgeClassTipo(tipo) {
      const classes = {
        'LICENCIA': 'bg-success',
        'MULTA': 'bg-warning',
        'OTROS': 'bg-info'
      }
      return classes[tipo] || 'bg-secondary'
    },

    getBadgeClassEstatus(estatus, diasVencido) {
      if (estatus === 'LIQUIDADO') return 'bg-primary'
      if (estatus === 'ACTIVO' && diasVencido > 0) return 'bg-danger'
      if (estatus === 'ACTIVO') return 'bg-success'
      return 'bg-secondary'
    },

    getEstatusDisplay(estatus, diasVencido) {
      if (estatus === 'LIQUIDADO') return 'LIQUIDADO'
      if (estatus === 'ACTIVO' && diasVencido > 0) return `VENCIDO (${diasVencido}d)`
      if (estatus === 'ACTIVO') return 'VIGENTE'
      return estatus
    },

    getBadgeClassParcialidad(estatus) {
      const classes = {
        'PAGADO': 'bg-success',
        'PENDIENTE': 'bg-secondary',
        'VENCIDO': 'bg-danger'
      }
      return classes[estatus] || 'bg-secondary'
    },

    getRowClassParcialidad(parcialidad) {
      if (parcialidad.estatus === 'PAGADO') return 'table-success'
      if (parcialidad.estatus === 'VENCIDO') return 'table-danger'
      return ''
    },

    getBadgeClassFormaPago(formaPago) {
      const classes = {
        'EFECTIVO': 'bg-success',
        'TRANSFERENCIA': 'bg-info',
        'CHEQUE': 'bg-warning',
        'TARJETA': 'bg-primary'
      }
      return classes[formaPago] || 'bg-secondary'
    },

    getPercentaje(valor, total) {
      if (!total || total === 0) return 0
      return Math.round((valor / total) * 100)
    },

    // Acciones adicionales
    exportarExcel() {
      this.$toast.info('Exportando a Excel...')
      // Implementar exportación
    },

    verRecibo(reciboId) {
      this.$toast.info(`Abriendo recibo: ${reciboId}`)
      // Implementar visualización de recibo
    },

    enviarEmailRecibo(reciboId) {
      this.$toast.info(`Enviando recibo por email: ${reciboId}`)
      // Implementar envío por email
    }
  },

  watch: {
    activeTab(newTab) {
      if (newTab === 'pagos') {
        this.cargarPagos()
      }
    }
  }
}
</script>

<style scoped>
.sistema-convenios {
  padding: 1rem;
}

.municipal-header {
  background: linear-gradient(135deg, #2c5aa0 0%, #1e3d6b 100%);
  color: white;
  padding: 2rem;
  border-radius: 0.75rem;
  margin-bottom: 2rem;
}

.municipal-title {
  font-size: 1.75rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.municipal-subtitle {
  font-size: 1rem;
  opacity: 0.9;
  margin-bottom: 0;
}

.municipal-stats .stat-card {
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 0.5rem;
  padding: 1rem;
  text-align: center;
  color: white;
}

.stat-number {
  font-size: 1.5rem;
  font-weight: 700;
}

.stat-label {
  font-size: 0.875rem;
  opacity: 0.8;
}

.municipal-tabs .nav-pills .nav-link {
  background: #f8f9fa;
  color: #6c757d;
  border: 1px solid #dee2e6;
  border-radius: 0.5rem;
  margin: 0 0.25rem;
  padding: 0.75rem 1.5rem;
  font-weight: 500;
  transition: all 0.3s ease;
}

.municipal-tabs .nav-pills .nav-link:hover {
  background: #e9ecef;
  color: #495057;
}

.municipal-tabs .nav-pills .nav-link.active {
  background: #2c5aa0;
  color: white;
  border-color: #2c5aa0;
}

.municipal-card {
  background: white;
  border: 1px solid #dee2e6;
  border-radius: 0.75rem;
  box-shadow: 0 0.125rem 0.25rem rgba(0, 0, 0, 0.075);
  overflow: hidden;
}

.municipal-card-header {
  background: #f8f9fa;
  border-bottom: 1px solid #dee2e6;
  padding: 1.25rem;
  font-weight: 600;
}

.municipal-controls {
  background: #f8f9fa;
  padding: 1.25rem;
  border-bottom: 1px solid #dee2e6;
}

.municipal-table {
  margin-bottom: 0;
}

.municipal-table th {
  background: #f8f9fa;
  border-bottom: 2px solid #dee2e6;
  font-weight: 600;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.025em;
  padding: 1rem 0.75rem;
}

.municipal-table td {
  padding: 0.875rem 0.75rem;
  vertical-align: middle;
}

.municipal-pagination {
  background: #f8f9fa;
  padding: 1rem 1.25rem;
  border-top: 1px solid #dee2e6;
}

.pagination-info {
  font-size: 0.875rem;
  color: #6c757d;
}

.btn-municipal-primary {
  background: #2c5aa0;
  border-color: #2c5aa0;
  color: white;
  font-weight: 500;
}

.btn-municipal-primary:hover {
  background: #1e3d6b;
  border-color: #1e3d6b;
  color: white;
}

.btn-outline-municipal {
  color: #2c5aa0;
  border-color: #2c5aa0;
}

.btn-outline-municipal:hover {
  background: #2c5aa0;
  border-color: #2c5aa0;
  color: white;
}

.municipal-modal-header {
  background: #2c5aa0;
  color: white;
}

.municipal-modal-header .btn-close {
  filter: invert(1);
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 0.75rem;
  border: none;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
  color: white;
}

.stat-content h3 {
  font-size: 1.75rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.stat-content p {
  font-size: 0.875rem;
  color: #6c757d;
  margin-bottom: 0;
}

.progress-item {
  margin-bottom: 1rem;
}

.progress-item:last-child {
  margin-bottom: 0;
}

.progress {
  height: 0.5rem;
  margin-top: 0.5rem;
}

.progress-bar {
  transition: width 0.6s ease;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .municipal-header {
    padding: 1.5rem;
  }

  .municipal-title {
    font-size: 1.5rem;
  }

  .municipal-stats {
    margin-top: 1rem;
  }

  .municipal-tabs .nav-pills .nav-link {
    padding: 0.5rem 1rem;
    font-size: 0.875rem;
  }

  .btn-group {
    flex-direction: column;
  }

  .btn-group .btn {
    margin-bottom: 0.25rem;
  }
}
</style>