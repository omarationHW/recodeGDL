<template>
  <div class="container-fluid py-4">
    <!-- Card con filtros -->
    <div class="municipal-card mb-3" style="min-height: 150px;">
      <div class="municipal-card-header">
        <h5 class="mb-0">Consulta de Pagos por Local</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Búsqueda -->
        <div class="row g-3">
          <div class="col-md-3">
            <label class="form-label">ID Local</label>
            <input v-model="form.id_local" type="number" class="form-control" @keyup.enter="buscar" />
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button class="btn btn-municipal-primary me-2" @click="buscar" :disabled="loading">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              Buscar
            </button>
            <button class="btn btn-outline-success" @click="abrirModal" :disabled="!form.id_local">
              <i class="bi bi-plus-circle me-1"></i> Agregar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de pagos (fuera del card) -->
    <div class="row mt-3">
      <div class="table-responsive ml-3 mr-3" style="height: 450px; overflow-y: scroll; margin:3dvb;">
        <table class="table table-sm table-striped table-hover municipal-table">
          <thead>
            <tr>
              <th>Control</th>
              <th>Año</th>
              <th>Mes</th>
              <th>Fecha</th>
              <th>Rec</th>
              <th>Caja</th>
              <th>Oper.</th>
              <th>Importe</th>
              <th>Partida</th>
              <th>Actualización</th>
              <th>Usuario</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pago in pagos" :key="pago.id_pago_local">
              <td>{{ pago.id_local }}</td>
              <td>{{ pago.axo }}</td>
              <td>{{ pago.periodo }}</td>
              <td>{{ formatDate(pago.fecha_pago) }}</td>
              <td>{{ pago.oficina_pago }}</td>
              <td>{{ pago.caja_pago }}</td>
              <td>{{ pago.operacion_pago }}</td>
              <td>{{ formatCurrency(pago.importe_pago) }}</td>
              <td>{{ pago.folio }}</td>
              <td>{{ formatDate(pago.fecha_modificacion) }}</td>
              <td>{{ pago.usuario }}</td>
              <td>
                <button class="btn btn-sm btn-outline-danger" @click="eliminar(pago)" title="Eliminar">
                  <i class="bi bi-trash">Eliminar</i>
                </button>
              </td>
            </tr>
            <tr v-if="!pagos.length && !loading">
              <td colspan="12" class="text-center text-muted py-3">No hay pagos para este local</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <div v-if="pagos.length" class="mt-2">
      <small class="text-muted">Total: {{ pagos.length }} pagos</small>
    </div>


    <!-- Modal Agregar Pago -->
    <div v-if="showModal" class="modal fade show d-block" tabindex="-1">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Agregar Pago</h5>
            <button type="button" class="btn-close" @click="showModal = false"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Año <span class="text-danger">*</span></label>
                <input v-model="newPago.axo" type="number" class="form-control" required />
              </div>
              <div class="col-md-6">
                <label class="form-label">Mes <span class="text-danger">*</span></label>
                <select v-model="newPago.periodo" class="form-select" required>
                  <option value="">Seleccione</option>
                  <option v-for="m in 12" :key="m" :value="m">{{ m }}</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label">Fecha Pago <span class="text-danger">*</span></label>
                <input v-model="newPago.fecha_pago" type="date" class="form-control" required />
              </div>
              <div class="col-md-6">
                <label class="form-label">Oficina</label>
                <input v-model="newPago.oficina_pago" type="number" class="form-control" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Caja</label>
                <input v-model="newPago.caja_pago" type="text" class="form-control" maxlength="10" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Operación</label>
                <input v-model="newPago.operacion_pago" type="number" class="form-control" />
              </div>
              <div class="col-md-6">
                <label class="form-label">Importe <span class="text-danger">*</span></label>
                <input v-model="newPago.importe_pago" type="number" step="0.01" class="form-control" required />
              </div>
              <div class="col-md-6">
                <label class="form-label">Partida/Folio</label>
                <input v-model="newPago.folio" type="text" class="form-control" maxlength="50" />
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="showModal = false">Cancelar</button>
            <button type="button" class="btn btn-municipal-primary" @click="agregarPago" :disabled="saving">
              <span v-if="saving" class="spinner-border spinner-border-sm me-1"></span>
              Agregar
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
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';

const loading = ref(false);
const saving = ref(false);
const pagos = ref([]);
const showModal = ref(false);

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
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: parseInt(form.value.id_local) }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      pagos.value = response.data.eResponse.data.result || [];
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
        Base: 'padron_licencias',
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
          Base: 'padron_licencias',
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
