<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Consulta de Pagos</h1>
        <p>Mercados - Consulta de Pagos por Local</p>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de Búsqueda -->
      <div class="municipal-card mb-4">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" class="me-2" />
            Búsqueda de Pagos
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row g-3 align-items-end">
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="hashtag" class="me-1" />
                ID Local <span class="required">*</span>
              </label>
              <input v-model="form.id_local" type="number" class="municipal-form-control"
                placeholder="Ingrese el ID del local" @keyup.enter="buscar" />
            </div>
            <div class="col-md-8">
              <div class="d-flex gap-2">
                <button class="btn-municipal-primary" @click="buscar" :disabled="loading || !form.id_local">
                  <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" class="me-2" />
                  {{ loading ? 'Buscando...' : 'Buscar' }}
                </button>
                <button class="btn-municipal-secondary" @click="abrirModal" :disabled="!form.id_local">
                  <font-awesome-icon icon="plus-circle" class="me-2" />
                  Agregar Pago
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Card de Resultados -->
      <div class="municipal-card" v-if="pagos.length > 0 || loading">
        <div class="municipal-card-header d-flex justify-content-between align-items-center">
          <h5 class="mb-0">
            <font-awesome-icon icon="list" class="me-2" />
            Resultados
          </h5>
          <span class="badge bg-municipal-primary" v-if="pagos.length > 0">
            {{ pagos.length }} {{ pagos.length === 1 ? 'registro' : 'registros' }}
          </span>
        </div>
        <div class="municipal-card-body p-0">
          <div class="table-responsive">
            <table class="table table-sm table-striped table-hover municipal-table mb-0">
              <thead class="table-light">
                <tr>
                  <th class="text-center" style="width: 50px;">#</th>
                  <th style="width: 80px;">Control</th>
                  <th style="width: 70px;">Año</th>
                  <th style="width: 60px;">Mes</th>
                  <th style="width: 110px;">Fecha Pago</th>
                  <th style="width: 60px;">Rec</th>
                  <th style="width: 60px;">Caja</th>
                  <th style="width: 80px;">Operación</th>
                  <th style="width: 120px;">Importe</th>
                  <th style="width: 150px;">Folio</th>
                  <th style="width: 150px;">Fecha Modificación</th>
                  <th style="width: 80px;">Usuario</th>
                  <th class="text-center" style="width: 100px;">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <template v-if="loading">
                  <tr>
                    <td colspan="13" class="text-center py-5">
                      <div class="d-flex flex-column align-items-center">
                        <font-awesome-icon icon="spinner" spin size="2x" class="text-municipal-primary mb-3" />
                        <span class="text-muted">Cargando pagos...</span>
                      </div>
                    </td>
                  </tr>
                </template>
                <template v-else-if="pagos.length === 0">
                  <tr>
                    <td colspan="13" class="text-center py-5">
                      <div class="d-flex flex-column align-items-center">
                        <font-awesome-icon icon="inbox" size="2x" class="text-muted mb-3" />
                        <span class="text-muted">No se encontraron pagos para este local</span>
                      </div>
                    </td>
                  </tr>
                </template>
                <template v-else>
                  <tr v-for="(pago, idx) in paginatedPagos" :key="pago.id_pago_local">
                    <td class="text-center text-muted">{{ (currentPage - 1) * itemsPerPage + idx + 1 }}</td>
                    <td class="fw-semibold">{{ pago.id_local }}</td>
                    <td>{{ pago.axo }}</td>
                    <td class="text-center">{{ pago.periodo }}</td>
                    <td>{{ formatDate(pago.fecha_pago) }}</td>
                    <td class="text-center">{{ pago.oficina_pago }}</td>
                    <td>{{ pago.caja_pago }}</td>
                    <td>{{ pago.operacion_pago }}</td>
                    <td class="text-end fw-semibold text-success">{{ formatCurrency(pago.importe_pago) }}</td>
                    <td><small>{{ pago.folio }}</small></td>
                    <td><small>{{ formatDate(pago.fecha_modificacion) }}</small></td>
                    <td class="text-center">{{ pago.id_usuario }}</td>
                    <td class="text-center">
                      <button class="btn btn-sm btn-outline-danger" @click="eliminar(pago)" title="Eliminar pago">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </td>
                  </tr>
                </template>
              </tbody>
            </table>
          </div>

          <!-- Paginación -->
          <div v-if="pagos.length > 0"
            class="d-flex justify-content-between align-items-center px-3 py-3 border-top bg-light">
            <div class="pagination-info">
              <small class="text-muted">
                Mostrando <strong>{{ ((currentPage - 1) * itemsPerPage) + 1 }}</strong>
                a <strong>{{ Math.min(currentPage * itemsPerPage, pagos.length) }}</strong>
                de <strong>{{ pagos.length }}</strong> registros
              </small>
            </div>

            <div class="d-flex align-items-center gap-3">
              <div class="d-flex align-items-center">
                <small class="text-muted me-2">Registros por página:</small>
                <select class="form-select form-select-sm" :value="itemsPerPage"
                  @change="changePageSize($event.target.value)" style="width: auto;">
                  <option value="10">10</option>
                  <option value="25">25</option>
                  <option value="50">50</option>
                  <option value="100">100</option>
                </select>
              </div>

              <div class="btn-group btn-group-sm">
                <button class="btn btn-outline-secondary" @click="goToPage(1)" :disabled="currentPage === 1"
                  title="Primera página">
                  <font-awesome-icon icon="angle-double-left" />
                </button>

                <button class="btn btn-outline-secondary" @click="goToPage(currentPage - 1)"
                  :disabled="currentPage === 1" title="Página anterior">
                  <font-awesome-icon icon="angle-left" />
                </button>

                <button v-for="page in visiblePages" :key="page" class="btn"
                  :class="page === currentPage ? 'btn-municipal-primary' : 'btn-outline-secondary'"
                  @click="goToPage(page)">
                  {{ page }}
                </button>

                <button class="btn btn-outline-secondary" @click="goToPage(currentPage + 1)"
                  :disabled="currentPage === totalPages" title="Página siguiente">
                  <font-awesome-icon icon="angle-right" />
                </button>

                <button class="btn btn-outline-secondary" @click="goToPage(totalPages)"
                  :disabled="currentPage === totalPages" title="Última página">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>


  <!-- Modal Agregar Pago -->
  <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
    <div class="modal-dialog modal-lg">
      <div class="modal-content">
        <div class="modal-header bg-municipal-primary text-white">
          <h5 class="modal-title">
            <font-awesome-icon icon="plus-circle" class="me-2" />
            Agregar Nuevo Pago
          </h5>
          <button type="button" class="btn-close btn-close-white" @click="showModal = false"></button>
        </div>
        <div class="modal-body">
          <div class="alert alert-info d-flex align-items-center mb-3">
            <font-awesome-icon icon="info-circle" class="me-2" />
            <small>Complete la información del pago. Los campos marcados con <span class="required">*</span> son
              obligatorios.</small>
          </div>

          <div class="row g-3">
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar" class="me-1" />
                Año <span class="required">*</span>
              </label>
              <input v-model="newPago.axo" type="number" class="municipal-form-control" placeholder="2025" required />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                Mes <span class="required">*</span>
              </label>
              <select v-model="newPago.periodo" class="municipal-form-control" required>
                <option value="">Seleccione un mes</option>
                <option v-for="m in 12" :key="m" :value="m">{{ m }} - {{ getNombreMes(m) }}</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="calendar-day" class="me-1" />
                Fecha de Pago <span class="required">*</span>
              </label>
              <input v-model="newPago.fecha_pago" type="date" class="municipal-form-control" required />
            </div>
            <div class="col-md-6">
              <label class="municipal-form-label">
                <font-awesome-icon icon="dollar-sign" class="me-1" />
                Importe <span class="required">*</span>
              </label>
              <input v-model="newPago.importe_pago" type="number" step="0.01" class="municipal-form-control"
                placeholder="0.00" required />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">
                <font-awesome-icon icon="building" class="me-1" />
                Oficina
              </label>
              <input v-model="newPago.oficina_pago" type="number" class="municipal-form-control"
                placeholder="Número de oficina" />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Caja</label>
              <input v-model="newPago.caja_pago" type="text" class="municipal-form-control" maxlength="10"
                placeholder="Ej: A, B, C" />
            </div>
            <div class="col-md-4">
              <label class="municipal-form-label">Operación</label>
              <input v-model="newPago.operacion_pago" type="number" class="municipal-form-control"
                placeholder="Número de operación" />
            </div>
            <div class="col-12">
              <label class="municipal-form-label">
                <font-awesome-icon icon="file-alt" class="me-1" />
                Partida/Folio
              </label>
              <input v-model="newPago.folio" type="text" class="municipal-form-control" maxlength="50"
                placeholder="Ingrese el folio o partida" />
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn-municipal-secondary" @click="showModal = false">
            <font-awesome-icon icon="times" class="me-2" />
            Cancelar
          </button>
          <button type="button" class="btn-municipal-primary" @click="agregarPago" :disabled="saving">
            <font-awesome-icon :icon="saving ? 'spinner' : 'save'" :spin="saving" class="me-2" />
            {{ saving ? 'Guardando...' : 'Guardar Pago' }}
          </button>
        </div>
      </div>
    </div>
  </div>
  <div v-if="showModal" class="modal-backdrop fade show"></div>

  <!-- Modal de Mensajes -->
  <div v-if="showMessageModal" class="modal fade show d-block" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header" :class="messageModal.headerClass">
          <h5 class="modal-title">{{ messageModal.title }}</h5>
          <button type="button" class="btn-close" @click="showMessageModal = false"></button>
        </div>
        <div class="modal-body">
          <p class="mb-0">{{ messageModal.message }}</p>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" @click="showMessageModal = false">Cerrar</button>
        </div>
      </div>
    </div>
  </div>
  <div v-if="showMessageModal" class="modal-backdrop fade show"></div>

  <!-- Modal de Confirmación -->
  <div v-if="showConfirmModal" class="modal fade show d-block" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content">
        <div class="modal-header bg-warning text-dark">
          <h5 class="modal-title">Confirmar</h5>
          <button type="button" class="btn-close" @click="showConfirmModal = false"></button>
        </div>
        <div class="modal-body">
          <p class="mb-0">{{ confirmMessage }}</p>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" @click="showConfirmModal = false">Cancelar</button>
          <button type="button" class="btn btn-warning" @click="ejecutarConfirm">Aceptar</button>
        </div>
      </div>
    </div>
  </div>
  <div v-if="showConfirmModal" class="modal-backdrop fade show"></div>
</template>

<script setup>
import { ref, computed } from 'vue';
import axios from 'axios';

const loading = ref(false);
const saving = ref(false);
const pagos = ref([]);
const showModal = ref(false);

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(10);

// Computed para paginación
const totalPages = computed(() => {
  return Math.ceil(pagos.value.length / itemsPerPage.value)
});

const paginatedPagos = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return pagos.value.slice(start, end)
});

const visiblePages = computed(() => {
  const pages = []
  const maxVisible = 5
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2))
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1)

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1)
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i)
  }

  return pages
});

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
};

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize)
  currentPage.value = 1
};

const resetPagination = () => {
  currentPage.value = 1
  itemsPerPage.value = 10
};

// Modal de mensajes
const showMessageModal = ref(false);
const messageModal = ref({
  title: '',
  message: '',
  headerClass: ''
});

// Modal de confirmación
const showConfirmModal = ref(false);
const confirmMessage = ref('');
const confirmCallback = ref(null);

const mostrarMensaje = (mensaje, tipo = 'info') => {
  const config = {
    success: { title: 'Éxito', headerClass: 'bg-success text-white' },
    error: { title: 'Error', headerClass: 'bg-danger text-white' },
    warning: { title: 'Advertencia', headerClass: 'bg-warning text-dark' },
    info: { title: 'Información', headerClass: 'bg-info text-white' }
  };
  messageModal.value = {
    title: config[tipo].title,
    message: mensaje,
    headerClass: config[tipo].headerClass
  };
  showMessageModal.value = true;
};

const mostrarConfirm = (mensaje, callback) => {
  confirmMessage.value = mensaje;
  confirmCallback.value = callback;
  showConfirmModal.value = true;
};

const ejecutarConfirm = () => {
  showConfirmModal.value = false;
  if (confirmCallback.value) {
    confirmCallback.value();
  }
};

const form = ref({
  id_local: ''
});

const newPago = ref({
  axo: new Date().getFullYear(),
  periodo: '',
  fecha_pago: '',
  oficina_pago: '',
  caja_pago: '',
  operacion_pago: '',
  importe_pago: '',
  folio: ''
});

const formatCurrency = (value) => {
  if (!value) return '$0.00';
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value);
};

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const buscar = async () => {
  if (!form.value.id_local) {
    mostrarMensaje('Ingrese el ID del local', 'warning');
    return;
  }

  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_pagos_get_by_local',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_id_local', Valor: parseInt(form.value.id_local) }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      pagos.value = response.data.eResponse.data.result || [];
      resetPagination();
      if (pagos.value.length === 0) {
        mostrarMensaje('No se encontraron pagos para este local', 'info');
      }
    }
  } catch (error) {
    console.error('Error al buscar pagos:', error);
    mostrarMensaje('Error al buscar pagos', 'error');
  } finally {
    loading.value = false;
  }
};

const abrirModal = () => {
  newPago.value = {
    axo: new Date().getFullYear(),
    periodo: '',
    fecha_pago: new Date().toISOString().split('T')[0],
    oficina_pago: '',
    caja_pago: '',
    operacion_pago: '',
    importe_pago: '',
    folio: ''
  };
  showModal.value = true;
};

const getNombreMes = (mes) => {
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
  return meses[mes - 1] || '';
};

const agregarPago = async () => {
  if (!newPago.value.axo || !newPago.value.periodo || !newPago.value.fecha_pago || !newPago.value.importe_pago) {
    mostrarMensaje('Complete los campos requeridos', 'warning');
    return;
  }

  saving.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_pagos_add',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_id_local', Valor: parseInt(form.value.id_local) },
          { Nombre: 'p_axo', Valor: parseInt(newPago.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(newPago.value.periodo) },
          { Nombre: 'p_fecha_pago', Valor: newPago.value.fecha_pago },
          { Nombre: 'p_oficina_pago', Valor: parseInt(newPago.value.oficina_pago) || 1 },
          { Nombre: 'p_caja_pago', Valor: newPago.value.caja_pago || '' },
          { Nombre: 'p_operacion_pago', Valor: parseInt(newPago.value.operacion_pago) || 0 },
          { Nombre: 'p_importe_pago', Valor: parseFloat(newPago.value.importe_pago) },
          { Nombre: 'p_folio', Valor: newPago.value.folio || '' },
          { Nombre: 'p_id_usuario', Valor: 1 }
        ]
      }
    });

    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result?.[0];
      if (result?.success !== false) {
        showModal.value = false;
        await buscar();
        mostrarMensaje('Pago agregado correctamente', 'success');
      } else {
        mostrarMensaje(result?.message || 'Error al agregar pago', 'error');
      }
    }
  } catch (error) {
    console.error('Error al agregar pago:', error);
    mostrarMensaje('Error al agregar pago', 'error');
  } finally {
    saving.value = false;
  }
};

const eliminar = (pago) => {
  mostrarConfirm(`¿Está seguro de eliminar el pago ${pago.axo}-${pago.periodo}?`, async () => {
    try {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cons_pagos_delete',
          Base: 'mercados',
          Esquema: 'publico',
          Parametros: [
            { Nombre: 'p_id_pago_local', Valor: pago.id_pago_local }
          ]
        }
      });

      if (response.data.eResponse?.success) {
        await buscar();
        mostrarMensaje('Pago eliminado correctamente', 'success');
      }
    } catch (error) {
      console.error('Error al eliminar pago:', error);
      mostrarMensaje('Error al eliminar pago', 'error');
    }
  });
};
</script>
