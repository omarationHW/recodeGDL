<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="edit" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Estacionamientos</h1>
        <p>Modificación, Baja, Cajones, Categoría, Adeudos y Multas</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="limpiarBusqueda" :disabled="loading">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Buscar Estacionamiento
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">No. Estacionamiento <span class="required">*</span></label>
              <input
                class="municipal-form-control"
                type="number"
                v-model.number="numEsta"
                placeholder="Ingrese número"
                @keyup.enter="buscarEstacionamiento"
              />
            </div>
            <div class="form-group form-group-buttons">
              <button class="btn-municipal-primary" @click="buscarEstacionamiento" :disabled="loading">
                <font-awesome-icon icon="search" /> Buscar
              </button>
            </div>
            <div class="form-group" v-if="estacionamiento">
              <span class="badge badge-lg" :class="estacionamiento.movto_cve === 'C' ? 'badge-danger' : 'badge-success'">
                <font-awesome-icon :icon="estacionamiento.movto_cve === 'C' ? 'ban' : 'check-circle'" />
                {{ estacionamiento.movto_cve === 'C' ? 'CANCELADO' : 'VIGENTE' }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Estacionamiento -->
      <div v-if="estacionamiento" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="parking" />
            Estacionamiento #{{ estacionamiento.numesta }}
          </h5>
          <div class="header-right">
            <span class="badge-purple">{{ estacionamiento.descripcion }}</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" /> Datos Generales
              </h6>
              <div class="info-list">
                <div class="info-item">
                  <span class="info-label">Nombre:</span>
                  <span class="info-value">{{ estacionamiento.nombre }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Dirección:</span>
                  <span class="info-value">{{ estacionamiento.calle }} {{ estacionamiento.numext }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Teléfono:</span>
                  <span class="info-value">{{ estacionamiento.telefono || 'N/A' }}</span>
                </div>
              </div>
            </div>
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="car" /> Información
              </h6>
              <div class="info-list">
                <div class="info-item">
                  <span class="info-label">Categoría:</span>
                  <span class="info-value">{{ estacionamiento.descripcion }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Cajones:</span>
                  <span class="info-value text-primary fw-bold">{{ estacionamiento.cupo }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">RFC:</span>
                  <span class="info-value">{{ estacionamiento.rfc || 'N/A' }}</span>
                </div>
              </div>
            </div>
            <div class="info-section">
              <h6 class="section-title">
                <font-awesome-icon icon="calendar-alt" /> Fechas
              </h6>
              <div class="info-list">
                <div class="info-item">
                  <span class="info-label">Alta:</span>
                  <span class="info-value">{{ formatDate(estacionamiento.fecha_at) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Inicial:</span>
                  <span class="info-value">{{ formatDate(estacionamiento.fecha_inicial) }}</span>
                </div>
                <div class="info-item">
                  <span class="info-label">Cve. Cuenta:</span>
                  <span class="info-value">{{ estacionamiento.cvecuenta }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabs de Operaciones -->
      <div v-if="estacionamiento && estacionamiento.movto_cve !== 'C'" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cogs" />
            Operaciones
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Tab Navigation -->
          <div class="municipal-tabs">
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'modificacion' }"
              @click="activeTab = 'modificacion'"
            >
              <font-awesome-icon icon="edit" /> Modificación
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'baja' }"
              @click="activeTab = 'baja'"
            >
              <font-awesome-icon icon="times-circle" /> Baja
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'cajones' }"
              @click="activeTab = 'cajones'"
            >
              <font-awesome-icon icon="car" /> Cajones
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'categoria' }"
              @click="activeTab = 'categoria'"
            >
              <font-awesome-icon icon="tags" /> Categoría
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'adeudos' }"
              @click="activeTab = 'adeudos'; loadAdeudos()"
            >
              <font-awesome-icon icon="dollar-sign" /> Adeudos
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'recibos' }"
              @click="activeTab = 'recibos'; loadRecibos()"
            >
              <font-awesome-icon icon="receipt" /> Recibos
            </button>
            <button
              class="municipal-tab"
              :class="{ active: activeTab === 'multas' }"
              @click="activeTab = 'multas'; loadMultas()"
            >
              <font-awesome-icon icon="exclamation-triangle" /> Multas
            </button>
          </div>

          <!-- Tab Content -->
          <div class="tab-content-area">
            <!-- Tab 1: Modificación -->
            <div v-if="activeTab === 'modificacion'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="edit" /> Modificar Datos del Estacionamiento</h6>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Calle</label>
                  <input class="municipal-form-control" v-model="formModif.calle" />
                </div>
                <div class="form-group form-group-sm">
                  <label class="municipal-form-label">No. Exterior</label>
                  <input class="municipal-form-control" v-model="formModif.numext" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Teléfono</label>
                  <input class="municipal-form-control" v-model="formModif.telefono" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Cve. Cuenta Predial</label>
                  <input class="municipal-form-control" type="number" v-model.number="formModif.cvecuenta" />
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">No. Licencia</label>
                  <input class="municipal-form-control" type="number" v-model.number="formModif.numlicencia" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Fecha Atención</label>
                  <input type="date" class="municipal-form-control" v-model="formModif.fecha_at" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Fecha Inicial</label>
                  <input type="date" class="municipal-form-control" v-model="formModif.fecha_inicial" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Fecha Vencimiento</label>
                  <input type="date" class="municipal-form-control" v-model="formModif.fecha_vencimiento" />
                </div>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Solicitud</label>
                  <input class="municipal-form-control" type="number" v-model.number="formModif.solicitud" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Control</label>
                  <input class="municipal-form-control" type="number" v-model.number="formModif.control" />
                </div>
              </div>
              <div class="form-actions">
                <button class="btn-municipal-primary" @click="guardarModificacion" :disabled="loading">
                  <font-awesome-icon icon="save" /> Guardar Cambios
                </button>
              </div>
            </div>

            <!-- Tab 2: Baja -->
            <div v-if="activeTab === 'baja'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="times-circle" /> Dar de Baja el Estacionamiento</h6>
              </div>
              <div class="alert alert-warning">
                <font-awesome-icon icon="exclamation-triangle" />
                <strong>Atención:</strong> Esta acción marcará el estacionamiento como CANCELADO y no podrá realizar más operaciones.
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Folio de Baja <span class="required">*</span></label>
                  <input class="municipal-form-control" type="number" v-model.number="formBaja.folio" placeholder="0" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Fecha de Baja <span class="required">*</span></label>
                  <input type="date" class="municipal-form-control" v-model="formBaja.fecbaja" />
                </div>
              </div>
              <div class="form-actions">
                <button class="btn-municipal-danger" @click="ejecutarBaja" :disabled="loading">
                  <font-awesome-icon icon="times-circle" /> Ejecutar Baja
                </button>
              </div>
            </div>

            <!-- Tab 3: Cajones -->
            <div v-if="activeTab === 'cajones'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="car" /> Incremento/Decremento de Cajones</h6>
              </div>
              <div class="stat-highlight">
                <span class="stat-label">Cajones Actuales:</span>
                <span class="stat-value">{{ estacionamiento.cupo }}</span>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Cantidad de Cajones <span class="required">*</span></label>
                  <input class="municipal-form-control" type="number" v-model.number="formCajones.cajones" placeholder="Ej: 5 o -3" />
                  <small class="form-text text-muted">Use valores negativos para decrementar</small>
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Fecha</label>
                  <input type="date" class="municipal-form-control" v-model="formCajones.fecha" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Oficio</label>
                  <input class="municipal-form-control" v-model="formCajones.oficio" />
                </div>
              </div>
              <div class="form-actions">
                <button class="btn-municipal-primary" @click="guardarCajones" :disabled="loading">
                  <font-awesome-icon icon="save" /> Aplicar Cambio
                </button>
              </div>
            </div>

            <!-- Tab 4: Categoría -->
            <div v-if="activeTab === 'categoria'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="tags" /> Cambio de Categoría</h6>
              </div>
              <div class="stat-highlight">
                <span class="stat-label">Categoría Actual:</span>
                <span class="stat-value">{{ estacionamiento.descripcion }}</span>
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label class="municipal-form-label">Nueva Categoría <span class="required">*</span></label>
                  <select class="municipal-form-control" v-model.number="formCategoria.categoria">
                    <option value="">Seleccione...</option>
                    <option v-for="cat in categorias" :key="cat.id" :value="cat.id">
                      {{ cat.descripcion }}
                    </option>
                  </select>
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Fecha</label>
                  <input type="date" class="municipal-form-control" v-model="formCategoria.fecha" />
                </div>
                <div class="form-group">
                  <label class="municipal-form-label">Oficio</label>
                  <input class="municipal-form-control" v-model="formCategoria.oficio" />
                </div>
              </div>
              <div class="form-actions">
                <button class="btn-municipal-primary" @click="guardarCategoria" :disabled="loading">
                  <font-awesome-icon icon="save" /> Cambiar Categoría
                </button>
              </div>
            </div>

            <!-- Tab 5: Adeudos -->
            <div v-if="activeTab === 'adeudos'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="dollar-sign" /> Adeudos del Estacionamiento</h6>
                <div class="header-right">
                  <span v-if="loadingAdeudos" class="loading-indicator">
                    <font-awesome-icon icon="spinner" spin /> Cargando...
                  </span>
                  <span v-else-if="adeudos.length > 0" class="badge-purple">{{ adeudos.length }} registros</span>
                </div>
              </div>
              <div v-if="loadingAdeudos" class="tab-loading">
                <font-awesome-icon icon="spinner" spin size="2x" />
                <p>Cargando adeudos...</p>
              </div>
              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Concepto</th>
                      <th>Año</th>
                      <th>Mes</th>
                      <th class="text-end">Adeudo</th>
                      <th class="text-end">Recargos</th>
                      <th class="text-end">Total</th>
                      <th>Acciones</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(adeudo, idx) in paginatedAdeudos" :key="idx" class="municipal-table-row row-hover" @dblclick="aplicarPago(adeudo)">
                      <td>{{ adeudo.concepto }}</td>
                      <td>{{ adeudo.axo }}</td>
                      <td>{{ adeudo.mes }}</td>
                      <td class="text-end">{{ formatMoney(adeudo.adeudo) }}</td>
                      <td class="text-end">{{ formatMoney(adeudo.recargos) }}</td>
                      <td class="text-end fw-bold">{{ formatMoney(Number(adeudo.adeudo) + Number(adeudo.recargos)) }}</td>
                      <td>
                        <div class="button-group button-group-sm">
                          <button class="btn-municipal-success btn-sm" @click="aplicarPago(adeudo)" title="Aplicar Pago">
                            <font-awesome-icon icon="check" />
                          </button>
                          <button class="btn-municipal-danger btn-sm" @click="borrarAdeudo(adeudo)" title="Borrar">
                            <font-awesome-icon icon="trash" />
                          </button>
                        </div>
                      </td>
                    </tr>
                    <tr v-if="adeudos.length === 0">
                      <td colspan="7" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
                        <p>Sin adeudos registrados</p>
                      </td>
                    </tr>
                  </tbody>
                  <tfoot v-if="adeudos.length > 0" class="municipal-table-footer">
                    <tr>
                      <td colspan="3" class="fw-bold">TOTALES</td>
                      <td class="text-end fw-bold">{{ formatMoney(totalAdeudo) }}</td>
                      <td class="text-end fw-bold">{{ formatMoney(totalRecargos) }}</td>
                      <td class="text-end fw-bold text-primary">{{ formatMoney(totalAdeudo + totalRecargos) }}</td>
                      <td></td>
                    </tr>
                  </tfoot>
                </table>
              </div>
              <!-- Paginación Adeudos -->
              <div v-if="totalPagesAdeudos > 1" class="pagination-container">
                <div class="pagination-info">
                  Mostrando {{ (currentPageAdeudos - 1) * pageSize + 1 }} - {{ Math.min(currentPageAdeudos * pageSize, adeudos.length) }} de {{ adeudos.length }}
                </div>
                <div class="pagination-controls">
                  <button class="pagination-btn" @click="goToPageAdeudos(1)" :disabled="currentPageAdeudos === 1">
                    <font-awesome-icon icon="angle-double-left" />
                  </button>
                  <button class="pagination-btn" @click="goToPageAdeudos(currentPageAdeudos - 1)" :disabled="currentPageAdeudos === 1">
                    <font-awesome-icon icon="angle-left" />
                  </button>
                  <span class="pagination-pages">Página {{ currentPageAdeudos }} de {{ totalPagesAdeudos }}</span>
                  <button class="pagination-btn" @click="goToPageAdeudos(currentPageAdeudos + 1)" :disabled="currentPageAdeudos === totalPagesAdeudos">
                    <font-awesome-icon icon="angle-right" />
                  </button>
                  <button class="pagination-btn" @click="goToPageAdeudos(totalPagesAdeudos)" :disabled="currentPageAdeudos === totalPagesAdeudos">
                    <font-awesome-icon icon="angle-double-right" />
                  </button>
                </div>
              </div>

              <!-- Panel de Aplicar Pago -->
              <div v-if="showPagoPanel" class="sub-panel sub-panel-success">
                <div class="sub-panel-header">
                  <font-awesome-icon icon="dollar-sign" /> Aplicar Pago - Año: {{ selectedAdeudo?.axo }} Mes: {{ selectedAdeudo?.mes }}
                </div>
                <div class="sub-panel-body">
                  <div class="form-row">
                    <div class="form-group">
                      <label class="municipal-form-label">Fecha Operación</label>
                      <input type="date" class="municipal-form-control" v-model="formPago.fecha" />
                    </div>
                    <div class="form-group form-group-sm">
                      <label class="municipal-form-label">Oficina</label>
                      <input class="municipal-form-control" type="number" v-model.number="formPago.reca" />
                    </div>
                    <div class="form-group form-group-sm">
                      <label class="municipal-form-label">Caja</label>
                      <input class="municipal-form-control" v-model="formPago.caja" />
                    </div>
                    <div class="form-group">
                      <label class="municipal-form-label">Operación</label>
                      <input class="municipal-form-control" type="number" v-model.number="formPago.operacion" />
                    </div>
                  </div>
                  <div class="form-actions">
                    <button class="btn-municipal-success" @click="confirmarPago" :disabled="loading">
                      <font-awesome-icon icon="check" /> Aplicar
                    </button>
                    <button class="btn-municipal-secondary" @click="showPagoPanel = false">
                      <font-awesome-icon icon="times" /> Cancelar
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <!-- Tab 6: Recibos -->
            <div v-if="activeTab === 'recibos'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="receipt" /> Recibos y Pagos</h6>
                <div class="header-right">
                  <span v-if="loadingRecibos" class="loading-indicator">
                    <font-awesome-icon icon="spinner" spin /> Cargando...
                  </span>
                  <span v-else-if="recibos.length > 0" class="badge-purple">{{ recibos.length }} registros</span>
                </div>
              </div>
              <div v-if="loadingRecibos" class="tab-loading">
                <font-awesome-icon icon="spinner" spin size="2x" />
                <p>Cargando recibos...</p>
              </div>
              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Fecha Movto</th>
                      <th>Recaudadora</th>
                      <th>Caja</th>
                      <th>Operación</th>
                      <th class="text-end">Importe</th>
                      <th>Registros</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr
                      v-for="(recibo, idx) in paginatedRecibos"
                      :key="idx"
                      @click="selectRecibo(recibo)"
                      :class="{ 'table-row-selected': selectedRecibo === recibo }"
                      class="municipal-table-row row-hover"
                    >
                      <td>{{ formatDate(recibo.fecha_movto) }}</td>
                      <td>{{ recibo.pag_reca }}</td>
                      <td>{{ recibo.pag_caja }}</td>
                      <td>{{ recibo.pag_operacion }}</td>
                      <td class="text-end fw-bold">{{ formatMoney(recibo.pag_importe) }}</td>
                      <td><span class="badge badge-secondary">{{ recibo.count }}</span></td>
                    </tr>
                    <tr v-if="recibos.length === 0">
                      <td colspan="6" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
                        <p>Sin recibos registrados</p>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <!-- Paginación Recibos -->
              <div v-if="totalPagesRecibos > 1" class="pagination-container">
                <div class="pagination-info">
                  Mostrando {{ (currentPageRecibos - 1) * pageSize + 1 }} - {{ Math.min(currentPageRecibos * pageSize, recibos.length) }} de {{ recibos.length }}
                </div>
                <div class="pagination-controls">
                  <button class="pagination-btn" @click="goToPageRecibos(1)" :disabled="currentPageRecibos === 1">
                    <font-awesome-icon icon="angle-double-left" />
                  </button>
                  <button class="pagination-btn" @click="goToPageRecibos(currentPageRecibos - 1)" :disabled="currentPageRecibos === 1">
                    <font-awesome-icon icon="angle-left" />
                  </button>
                  <span class="pagination-pages">Página {{ currentPageRecibos }} de {{ totalPagesRecibos }}</span>
                  <button class="pagination-btn" @click="goToPageRecibos(currentPageRecibos + 1)" :disabled="currentPageRecibos === totalPagesRecibos">
                    <font-awesome-icon icon="angle-right" />
                  </button>
                  <button class="pagination-btn" @click="goToPageRecibos(totalPagesRecibos)" :disabled="currentPageRecibos === totalPagesRecibos">
                    <font-awesome-icon icon="angle-double-right" />
                  </button>
                </div>
              </div>
            </div>

            <!-- Tab 7: Multas -->
            <div v-if="activeTab === 'multas'" class="tab-panel">
              <div class="panel-header">
                <h6><font-awesome-icon icon="exclamation-triangle" /> Multas Relacionadas</h6>
                <div class="header-right">
                  <span v-if="loadingMultas" class="loading-indicator">
                    <font-awesome-icon icon="spinner" spin /> Cargando...
                  </span>
                  <span v-else-if="multas.length > 0" class="badge-purple">{{ multas.length }} registros</span>
                </div>
              </div>
              <div v-if="loadingMultas" class="tab-loading">
                <font-awesome-icon icon="spinner" spin size="2x" />
                <p>Cargando multas...</p>
              </div>
              <div v-else class="table-responsive">
                <table class="municipal-table">
                  <thead class="municipal-table-header">
                    <tr>
                      <th>Folio</th>
                      <th>Fecha</th>
                      <th>Concepto</th>
                      <th class="text-end">Importe</th>
                      <th>Estatus</th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(multa, idx) in paginatedMultas" :key="idx" class="municipal-table-row row-hover">
                      <td><strong class="text-primary">{{ multa.folio }}</strong></td>
                      <td>{{ formatDate(multa.fecha) }}</td>
                      <td>{{ multa.concepto }}</td>
                      <td class="text-end fw-bold">{{ formatMoney(multa.importe) }}</td>
                      <td>
                        <span class="badge" :class="multa.pagado ? 'badge-success' : 'badge-danger'">
                          <font-awesome-icon :icon="multa.pagado ? 'check-circle' : 'clock'" />
                          {{ multa.pagado ? 'PAGADO' : 'PENDIENTE' }}
                        </span>
                      </td>
                    </tr>
                    <tr v-if="multas.length === 0">
                      <td colspan="5" class="text-center text-muted">
                        <font-awesome-icon icon="inbox" size="2x" class="empty-state-icon" />
                        <p>Sin multas registradas</p>
                      </td>
                    </tr>
                  </tbody>
                </table>
              </div>
              <!-- Paginación Multas -->
              <div v-if="totalPagesMultas > 1" class="pagination-container">
                <div class="pagination-info">
                  Mostrando {{ (currentPageMultas - 1) * pageSize + 1 }} - {{ Math.min(currentPageMultas * pageSize, multas.length) }} de {{ multas.length }}
                </div>
                <div class="pagination-controls">
                  <button class="pagination-btn" @click="goToPageMultas(1)" :disabled="currentPageMultas === 1">
                    <font-awesome-icon icon="angle-double-left" />
                  </button>
                  <button class="pagination-btn" @click="goToPageMultas(currentPageMultas - 1)" :disabled="currentPageMultas === 1">
                    <font-awesome-icon icon="angle-left" />
                  </button>
                  <span class="pagination-pages">Página {{ currentPageMultas }} de {{ totalPagesMultas }}</span>
                  <button class="pagination-btn" @click="goToPageMultas(currentPageMultas + 1)" :disabled="currentPageMultas === totalPagesMultas">
                    <font-awesome-icon icon="angle-right" />
                  </button>
                  <button class="pagination-btn" @click="goToPageMultas(totalPagesMultas)" :disabled="currentPageMultas === totalPagesMultas">
                    <font-awesome-icon icon="angle-double-right" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje si está cancelado -->
      <div v-if="estacionamiento && estacionamiento.movto_cve === 'C'" class="alert alert-danger alert-prominent">
        <font-awesome-icon icon="ban" size="2x" />
        <div class="alert-content">
          <strong>Estacionamiento Cancelado</strong>
          <p>Este estacionamiento está CANCELADO. No se pueden realizar operaciones.</p>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda y Documentación -->
    <DocumentationModal
      :show="showDocModal"
      :componentName="'ActualizacionPublicos'"
      :moduleName="'estacionamiento_publico'"
      :docType="docType"
      :title="'Actualización de Estacionamientos'"
      @close="showDocModal = false"
    />

    <!-- Modal Detalle de Recibo -->
    <Teleport to="body">
      <div v-if="showModalDetalleRecibo" class="modal-overlay" @click.self="closeModalDetalleRecibo">
        <div class="modal-container modal-lg">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="receipt" />
              Detalle del Recibo
            </h5>
            <button class="modal-close" @click="closeModalDetalleRecibo">
              <font-awesome-icon icon="times" />
            </button>
          </div>
          <div class="modal-body">
            <!-- Info del Recibo -->
            <div class="info-grid info-grid-4" v-if="selectedRecibo">
              <div class="info-item-compact">
                <span class="info-label">Fecha:</span>
                <span class="info-value">{{ formatDate(selectedRecibo.fecha_movto) }}</span>
              </div>
              <div class="info-item-compact">
                <span class="info-label">Recaudadora:</span>
                <span class="info-value">{{ selectedRecibo.pag_reca }}</span>
              </div>
              <div class="info-item-compact">
                <span class="info-label">Caja:</span>
                <span class="info-value">{{ selectedRecibo.pag_caja }}</span>
              </div>
              <div class="info-item-compact">
                <span class="info-label">Operación:</span>
                <span class="info-value fw-bold text-primary">{{ selectedRecibo.pag_operacion }}</span>
              </div>
            </div>

            <!-- Tabla de Detalle -->
            <div class="table-responsive mt-3">
              <table class="municipal-table municipal-table-sm">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Tipo</th>
                    <th>Concepto</th>
                    <th>Año</th>
                    <th>Mes</th>
                    <th class="text-end">Importe</th>
                    <th class="text-end">Descuento</th>
                    <th class="text-end">Recargos</th>
                    <th class="text-end">Total</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(det, idx) in detalleRecibo" :key="idx" class="municipal-table-row">
                    <td>{{ det.tipo }}</td>
                    <td>{{ det.concepto }}</td>
                    <td>{{ det.axo }}</td>
                    <td>{{ det.mes }}</td>
                    <td class="text-end">{{ formatMoney(det.ade_importe) }}</td>
                    <td class="text-end">{{ formatMoney(det.ade_descto) }}</td>
                    <td class="text-end">{{ formatMoney(det.ade_recgos) }}</td>
                    <td class="text-end fw-bold text-primary">{{ formatMoney(det.total) }}</td>
                  </tr>
                  <tr v-if="detalleRecibo.length === 0">
                    <td colspan="8" class="text-center text-muted">
                      <font-awesome-icon icon="inbox" class="empty-state-icon" />
                      <p>Sin detalle disponible</p>
                    </td>
                  </tr>
                </tbody>
                <tfoot v-if="detalleRecibo.length > 0" class="municipal-table-footer">
                  <tr>
                    <td colspan="4" class="fw-bold">TOTAL</td>
                    <td class="text-end fw-bold">{{ formatMoney(detalleRecibo.reduce((s, d) => s + Number(d.ade_importe || 0), 0)) }}</td>
                    <td class="text-end fw-bold">{{ formatMoney(detalleRecibo.reduce((s, d) => s + Number(d.ade_descto || 0), 0)) }}</td>
                    <td class="text-end fw-bold">{{ formatMoney(detalleRecibo.reduce((s, d) => s + Number(d.ade_recgos || 0), 0)) }}</td>
                    <td class="text-end fw-bold text-primary">{{ formatMoney(detalleRecibo.reduce((s, d) => s + Number(d.total || 0), 0)) }}</td>
                  </tr>
                </tfoot>
              </table>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn-municipal-secondary" @click="closeModalDetalleRecibo">
              <font-awesome-icon icon="times" /> Cerrar
            </button>
          </div>
        </div>
      </div>
    </Teleport>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref, computed, nextTick } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

const BASE_DB = 'estacionamiento_publico'
const BASE_SCHEMA = 'publico'
const { loading, execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const numEsta = ref(null)
const estacionamiento = ref(null)
const activeTab = ref('modificacion')
const categorias = ref([])
const adeudos = ref([])
const recibos = ref([])
const detalleRecibo = ref([])
const multas = ref([])
const selectedRecibo = ref(null)
const selectedAdeudo = ref(null)
const showPagoPanel = ref(false)
const showModalDetalleRecibo = ref(false)

// Paginación
const pageSize = 10
const currentPageAdeudos = ref(1)
const currentPageRecibos = ref(1)
const currentPageMultas = ref(1)

// Loading de tabs
const loadingAdeudos = ref(false)
const loadingRecibos = ref(false)
const loadingMultas = ref(false)

// Formularios
const formModif = reactive({
  calle: '',
  numext: '',
  telefono: '',
  cvecuenta: 0,
  numlicencia: 0,
  fecha_at: '',
  fecha_inicial: '',
  fecha_vencimiento: '',
  solicitud: 0,
  control: 0
})

const formBaja = reactive({
  folio: 0,
  fecbaja: new Date().toISOString().split('T')[0]
})

const formCajones = reactive({
  cajones: 0,
  fecha: new Date().toISOString().split('T')[0],
  oficio: ''
})

const formCategoria = reactive({
  categoria: '',
  fecha: new Date().toISOString().split('T')[0],
  oficio: ''
})

const formPago = reactive({
  fecha: new Date().toISOString().split('T')[0],
  reca: 0,
  caja: '',
  operacion: 0
})

// Computed
const totalAdeudo = computed(() => adeudos.value.reduce((sum, a) => sum + Number(a.adeudo || 0), 0))
const totalRecargos = computed(() => adeudos.value.reduce((sum, a) => sum + Number(a.recargos || 0), 0))

// Paginación - Computed
const totalPagesAdeudos = computed(() => Math.ceil(adeudos.value.length / pageSize))
const totalPagesRecibos = computed(() => Math.ceil(recibos.value.length / pageSize))
const totalPagesMultas = computed(() => Math.ceil(multas.value.length / pageSize))

const paginatedAdeudos = computed(() => {
  const start = (currentPageAdeudos.value - 1) * pageSize
  return adeudos.value.slice(start, start + pageSize)
})

const paginatedRecibos = computed(() => {
  const start = (currentPageRecibos.value - 1) * pageSize
  return recibos.value.slice(start, start + pageSize)
})

const paginatedMultas = computed(() => {
  const start = (currentPageMultas.value - 1) * pageSize
  return multas.value.slice(start, start + pageSize)
})

// Funciones de paginación
function goToPageAdeudos(page) {
  if (page >= 1 && page <= totalPagesAdeudos.value) currentPageAdeudos.value = page
}

function goToPageRecibos(page) {
  if (page >= 1 && page <= totalPagesRecibos.value) currentPageRecibos.value = page
}

function goToPageMultas(page) {
  if (page >= 1 && page <= totalPagesMultas.value) currentPageMultas.value = page
}

// Helpers
function formatDate(date) {
  if (!date) return 'N/A'
  return new Date(date).toLocaleDateString('es-MX')
}

function formatMoney(value) {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0)
}

function limpiarBusqueda() {
  numEsta.value = null
  estacionamiento.value = null
  activeTab.value = 'modificacion'
  adeudos.value = []
  recibos.value = []
  multas.value = []
  detalleRecibo.value = []
  showPagoPanel.value = false
}

/**
 * Busca estacionamiento por número
 */
async function buscarEstacionamiento() {
  if (!numEsta.value) {
    showToast('warning', 'Ingrese el número de estacionamiento')
    return
  }

  try {
    showLoading('Buscando...', 'Consultando datos del estacionamiento')

    const parametros = [{ nombre: 'p_numesta', valor: numEsta.value, tipo: 'integer' }]
    const resp = await execute('sp_get_estacionamiento_by_numesta', BASE_DB, parametros, '', null, BASE_SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || null

    if (!data || !data.id) {
      estacionamiento.value = null
      showToast('warning', `No se encontró estacionamiento con número ${numEsta.value}`)
      return
    }

    estacionamiento.value = data
    // Cargar datos en formulario de modificación
    formModif.calle = data.calle || ''
    formModif.numext = data.numext || ''
    formModif.telefono = data.telefono || ''
    formModif.cvecuenta = data.cvecuenta || 0
    formModif.numlicencia = data.numlicencia || 0
    formModif.fecha_at = data.fecha_at ? data.fecha_at.split('T')[0] : ''
    formModif.fecha_inicial = data.fecha_inicial ? data.fecha_inicial.split('T')[0] : ''
    formModif.fecha_vencimiento = data.fecha_vencimiento ? data.fecha_vencimiento.split('T')[0] : ''
    formModif.solicitud = data.solicitud || 0
    formModif.control = data.control || 0

    showToast('success', `Estacionamiento #${data.numesta} encontrado`)

    // Cargar categorías
    await loadCategorias()

  } catch (e) {
    handleApiError(e, 'Error al buscar estacionamiento')
  } finally {
    hideLoading()
  }
}

/**
 * Carga catálogo de categorías
 */
async function loadCategorias() {
  try {
    const resp = await execute('sp_get_categorias_publicos', BASE_DB, [], '', null, BASE_SCHEMA)
    categorias.value = resp?.result || resp?.data?.result || resp?.data || []
  } catch (e) {
    console.error('Error cargando categorías:', e)
  }
}

/**
 * Carga adeudos del estacionamiento
 */
async function loadAdeudos() {
  if (!estacionamiento.value?.id) return

  try {
    loadingAdeudos.value = true
    const parametros = [
      { nombre: 'p_opc', valor: 1, tipo: 'integer' },
      { nombre: 'p_pubid', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_axo', valor: 0, tipo: 'integer' },
      { nombre: 'p_mes', valor: 0, tipo: 'integer' }
    ]
    const resp = await execute('cajero_pub_detalle', BASE_DB, parametros, '', null, BASE_SCHEMA)
    adeudos.value = resp?.result || resp?.data?.result || resp?.data || []
    currentPageAdeudos.value = 1
  } catch (e) {
    handleApiError(e, 'Error al cargar adeudos')
  } finally {
    loadingAdeudos.value = false
  }
}

/**
 * Carga recibos del estacionamiento
 */
async function loadRecibos() {
  if (!estacionamiento.value?.id) return

  try {
    loadingRecibos.value = true
    const parametros = [{ nombre: 'p_pubmain_id', valor: estacionamiento.value.id, tipo: 'integer' }]
    const resp = await execute('sp_get_recibos_publicos', BASE_DB, parametros, '', null, BASE_SCHEMA)
    recibos.value = resp?.result || resp?.data?.result || resp?.data || []
    detalleRecibo.value = []
    selectedRecibo.value = null
    currentPageRecibos.value = 1
  } catch (e) {
    handleApiError(e, 'Error al cargar recibos')
  } finally {
    loadingRecibos.value = false
  }
}

/**
 * Selecciona un recibo y carga su detalle en modal
 */
async function selectRecibo(recibo) {
  selectedRecibo.value = recibo

  try {
    const parametros = [
      { nombre: 'p_pubmain_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_fecha_movto', valor: recibo.fecha_movto, tipo: 'date' },
      { nombre: 'p_pag_reca', valor: recibo.pag_reca, tipo: 'integer' },
      { nombre: 'p_pag_caja', valor: recibo.pag_caja, tipo: 'string' },
      { nombre: 'p_pag_operacion', valor: recibo.pag_operacion, tipo: 'integer' }
    ]
    const resp = await execute('sp_get_detalle_recibo_publicos', BASE_DB, parametros, '', null, BASE_SCHEMA)
    detalleRecibo.value = resp?.result || resp?.data?.result || resp?.data || []
    showModalDetalleRecibo.value = true
  } catch (e) {
    handleApiError(e, 'Error al cargar detalle')
  }
}

/**
 * Cierra el modal de detalle de recibo
 */
function closeModalDetalleRecibo() {
  showModalDetalleRecibo.value = false
}

/**
 * Carga multas relacionadas
 */
async function loadMultas() {
  if (!estacionamiento.value?.id) return

  try {
    loadingMultas.value = true
    const parametros = [{ nombre: 'p_numesta', valor: estacionamiento.value.id, tipo: 'integer' }]
    const resp = await execute('sp_get_multas_publicos', BASE_DB, parametros, '', null, BASE_SCHEMA)
    multas.value = resp?.result || resp?.data?.result || resp?.data || []
    currentPageMultas.value = 1
  } catch (e) {
    handleApiError(e, 'Error al cargar multas')
  } finally {
    loadingMultas.value = false
  }
}

/**
 * Guarda modificación de datos
 */
async function guardarModificacion() {
  try {
    const result = await Swal.fire({
      icon: 'question',
      title: 'Confirmar Modificación',
      text: '¿Está seguro de guardar los cambios?',
      showCancelButton: true,
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, guardar',
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) return

    showLoading('Guardando...', 'Actualizando datos del estacionamiento')

    let sector = 'J'
    if (estacionamiento.value.sector) sector = estacionamiento.value.sector

    const parametros = [
      { nombre: 'p_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_sector', valor: sector, tipo: 'string' },
      { nombre: 'p_zona', valor: estacionamiento.value.zona || 0, tipo: 'integer' },
      { nombre: 'p_subzona', valor: estacionamiento.value.subzona || 0, tipo: 'integer' },
      { nombre: 'p_numlicencia', valor: formModif.numlicencia, tipo: 'integer' },
      { nombre: 'p_cvecuenta', valor: formModif.cvecuenta, tipo: 'integer' },
      { nombre: 'p_calle', valor: formModif.calle, tipo: 'string' },
      { nombre: 'p_numext', valor: formModif.numext, tipo: 'string' },
      { nombre: 'p_telefono', valor: formModif.telefono, tipo: 'string' },
      { nombre: 'p_fecha_at', valor: formModif.fecha_at || null, tipo: 'date' },
      { nombre: 'p_fecha_inicial', valor: formModif.fecha_inicial || null, tipo: 'date' },
      { nombre: 'p_fecha_vencimiento', valor: formModif.fecha_vencimiento || null, tipo: 'date' },
      { nombre: 'p_movto_cve', valor: 'M', tipo: 'string' },
      { nombre: 'p_movto_usr', valor: 1, tipo: 'integer' },
      { nombre: 'p_solicitud', valor: formModif.solicitud, tipo: 'integer' },
      { nombre: 'p_control', valor: formModif.control, tipo: 'integer' }
    ]

    const resp = await execute('sppubmodi', BASE_DB, parametros, '', null, BASE_SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()
    if (data?.result === 0) {
      await Swal.fire({ icon: 'success', title: 'Éxito', text: data?.resultstr || 'Datos actualizados correctamente', confirmButtonColor: '#ea8215', timer: 2000, timerProgressBar: true })
      await buscarEstacionamiento()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: data?.resultstr || 'No se pudo actualizar', confirmButtonColor: '#ea8215' })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

/**
 * Ejecuta baja del estacionamiento
 */
async function ejecutarBaja() {
  if (!formBaja.fecbaja) {
    Swal.fire({ icon: 'warning', title: 'Campo requerido', text: 'Ingrese la fecha de baja', confirmButtonColor: '#ea8215' })
    return
  }

  try {
    const result = await Swal.fire({
      icon: 'warning',
      title: 'Confirmar Baja',
      text: '¿Está seguro de dar de BAJA este estacionamiento? Esta acción lo marcará como CANCELADO.',
      showCancelButton: true,
      confirmButtonColor: '#dc3545',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, dar de baja',
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) return

    showLoading('Procesando...', 'Ejecutando baja del estacionamiento')

    const parametros = [
      { nombre: 'p_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_movto_cve', valor: 'C', tipo: 'string' },
      { nombre: 'p_movto_usr', valor: 1, tipo: 'integer' },
      { nombre: 'p_folio', valor: formBaja.folio, tipo: 'integer' },
      { nombre: 'p_fecbaja', valor: formBaja.fecbaja, tipo: 'date' }
    ]

    const resp = await execute('sppubbaja', BASE_DB, parametros, '', null, BASE_SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()
    if (data?.result === 0) {
      await Swal.fire({ icon: 'success', title: 'Éxito', text: data?.resultstr || 'Baja exitosa', confirmButtonColor: '#ea8215', timer: 2000, timerProgressBar: true })
      await buscarEstacionamiento()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: data?.resultstr || 'No se pudo realizar la baja', confirmButtonColor: '#ea8215' })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

/**
 * Guarda cambio de cajones
 */
async function guardarCajones() {
  if (!formCajones.cajones) {
    Swal.fire({ icon: 'warning', title: 'Campo requerido', text: 'Ingrese la cantidad de cajones', confirmButtonColor: '#ea8215' })
    return
  }

  try {
    const result = await Swal.fire({
      icon: 'question',
      title: 'Confirmar Cambio',
      text: `¿Está seguro de ${formCajones.cajones > 0 ? 'incrementar' : 'decrementar'} ${Math.abs(formCajones.cajones)} cajones?`,
      showCancelButton: true,
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, aplicar',
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) return

    showLoading('Procesando...', 'Aplicando cambio de cajones')

    const parametros = [
      { nombre: 'p_opc', valor: 1, tipo: 'integer' },
      { nombre: 'p_pubmain_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_fecha', valor: formCajones.fecha || null, tipo: 'date' },
      { nombre: 'p_cajones', valor: formCajones.cajones, tipo: 'integer' },
      { nombre: 'p_categoria', valor: 0, tipo: 'integer' },
      { nombre: 'p_oficio', valor: formCajones.oficio || '', tipo: 'string' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
    ]

    const resp = await execute('sp_pub_movtos', BASE_DB, parametros, '', null, BASE_SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()
    if (data?.resultado === 0) {
      await Swal.fire({ icon: 'success', title: 'Éxito', text: 'Cambio de cajones aplicado correctamente', confirmButtonColor: '#ea8215', timer: 2000, timerProgressBar: true })
      formCajones.cajones = 0
      formCajones.oficio = ''
      await buscarEstacionamiento()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: 'Verifique sus datos', confirmButtonColor: '#ea8215' })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

/**
 * Guarda cambio de categoría
 */
async function guardarCategoria() {
  if (!formCategoria.categoria) {
    Swal.fire({ icon: 'warning', title: 'Campo requerido', text: 'Seleccione una categoría', confirmButtonColor: '#ea8215' })
    return
  }

  try {
    const result = await Swal.fire({
      icon: 'question',
      title: 'Confirmar Cambio',
      text: '¿Está seguro de cambiar la categoría?',
      showCancelButton: true,
      confirmButtonColor: '#ea8215',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, cambiar',
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) return

    showLoading('Procesando...', 'Aplicando cambio de categoría')

    const parametros = [
      { nombre: 'p_opc', valor: 2, tipo: 'integer' },
      { nombre: 'p_pubmain_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_fecha', valor: formCategoria.fecha || null, tipo: 'date' },
      { nombre: 'p_cajones', valor: 0, tipo: 'integer' },
      { nombre: 'p_categoria', valor: formCategoria.categoria, tipo: 'integer' },
      { nombre: 'p_oficio', valor: formCategoria.oficio || '', tipo: 'string' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
    ]

    const resp = await execute('sp_pub_movtos', BASE_DB, parametros, '', null, BASE_SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()
    if (data?.resultado === 0) {
      await Swal.fire({ icon: 'success', title: 'Éxito', text: 'Categoría actualizada correctamente', confirmButtonColor: '#ea8215', timer: 2000, timerProgressBar: true })
      formCategoria.categoria = ''
      formCategoria.oficio = ''
      await buscarEstacionamiento()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: 'Verifique sus datos', confirmButtonColor: '#ea8215' })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

/**
 * Muestra panel para aplicar pago
 */
function aplicarPago(adeudo) {
  selectedAdeudo.value = adeudo
  showPagoPanel.value = true
  formPago.fecha = new Date().toISOString().split('T')[0]
  formPago.reca = 0
  formPago.caja = ''
  formPago.operacion = 0
}

/**
 * Confirma y aplica el pago
 */
async function confirmarPago() {
  if (!selectedAdeudo.value) return

  try {
    showLoading('Aplicando...', 'Procesando pago')

    const parametros = [
      { nombre: 'p_opc', valor: 1, tipo: 'integer' },
      { nombre: 'p_pubmain_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_axo', valor: selectedAdeudo.value.axo, tipo: 'integer' },
      { nombre: 'p_mes', valor: selectedAdeudo.value.mes, tipo: 'integer' },
      { nombre: 'p_tipo', valor: 10, tipo: 'integer' },
      { nombre: 'p_fecha', valor: formPago.fecha, tipo: 'date' },
      { nombre: 'p_reca', valor: formPago.reca, tipo: 'integer' },
      { nombre: 'p_caja', valor: formPago.caja, tipo: 'string' },
      { nombre: 'p_operacion', valor: formPago.operacion, tipo: 'integer' }
    ]

    const resp = await execute('actualiza_pub_pago', BASE_DB, parametros, '', null, BASE_SCHEMA)
    const data = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    hideLoading()
    await nextTick()
    if (data?.id === 0 || data?.id === 1) {
      await Swal.fire({ icon: 'success', title: 'Éxito', text: data?.mensaje || 'Pago aplicado correctamente', confirmButtonColor: '#ea8215', timer: 2000, timerProgressBar: true })
      showPagoPanel.value = false
      selectedAdeudo.value = null
      await loadAdeudos()
    } else {
      await Swal.fire({ icon: 'error', title: 'Error', text: data?.mensaje || 'No se pudo aplicar el pago', confirmButtonColor: '#ea8215' })
    }
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

/**
 * Borra un adeudo
 */
async function borrarAdeudo(adeudo) {
  try {
    const result = await Swal.fire({
      icon: 'warning',
      title: 'Confirmar Eliminación',
      text: `¿Está seguro de eliminar el adeudo del año ${adeudo.axo} mes ${adeudo.mes}?`,
      showCancelButton: true,
      confirmButtonColor: '#dc3545',
      cancelButtonColor: '#6c757d',
      confirmButtonText: 'Sí, eliminar',
      cancelButtonText: 'Cancelar'
    })

    if (!result.isConfirmed) return

    showLoading('Eliminando...', 'Borrando adeudo')

    const parametros = [
      { nombre: 'p_pubmain_id', valor: estacionamiento.value.id, tipo: 'integer' },
      { nombre: 'p_axo', valor: adeudo.axo, tipo: 'integer' },
      { nombre: 'p_mes', valor: adeudo.mes, tipo: 'integer' }
    ]

    await execute('delete_pubadeudo', BASE_DB, parametros, '', null, BASE_SCHEMA)
    hideLoading()
    await nextTick()
    await Swal.fire({ icon: 'success', title: 'Éxito', text: 'Adeudo eliminado correctamente', confirmButtonColor: '#ea8215', timer: 2000, timerProgressBar: true })
    await loadAdeudos()
  } catch (e) {
    hideLoading()
    await nextTick()
    handleApiError(e)
  }
}

// Documentación y Ayuda
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}
</script>
