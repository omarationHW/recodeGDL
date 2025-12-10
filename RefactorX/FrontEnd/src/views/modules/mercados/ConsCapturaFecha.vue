<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="calendar-alt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Captura por Fecha</h1>
        <p>Mercados - Detalle de Pagos Capturados por Fecha</p>
      </div>
      <div class="button-group ms-auto"></div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Criterios de Búsqueda
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarPagos">
            <div class="row">
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Fecha Pago *</label>
                <input type="date" class="municipal-form-control" v-model="form.fecha" required />
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Oficina *</label>
                <select class="municipal-form-control" v-model="form.oficina" required>
                  <option value="">Seleccione...</option>
                  <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">
                    {{ of.id_rec }} - {{ of.recaudadora }}
                  </option>
                </select>
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Caja *</label>
                <input type="text" class="municipal-form-control" v-model="form.caja" required maxlength="10" />
              </div>
              <div class="col-md-3 mb-3">
                <label class="municipal-form-label">Operación *</label>
                <input type="number" class="municipal-form-control" v-model.number="form.operacion" required min="1" />
              </div>
            </div>
            <button type="submit" class="btn-municipal-primary" :disabled="loading">
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </form>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos Encontrados
            <span v-if="pagos.length > 0" class="badge bg-primary ms-2">{{ pagos.length }}</span>
          </h5>
          <button v-if="selected.length > 0" class="btn-municipal-danger btn-sm ms-auto" @click="borrarPagos">
            <font-awesome-icon icon="trash" />
            Borrar ({{ selected.length }})
          </button>
        </div>
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status"></div>
          </div>

          <div v-else-if="pagos.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th style="width: 40px;">
                    <input type="checkbox" class="form-check-input" v-model="selectAll" @change="toggleAll" />
                  </th>
                  <th>ID</th>
                  <th>Datos Local</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha</th>
                  <th>Oficina</th>
                  <th>Caja</th>
                  <th>Oper.</th>
                  <th>Importe</th>
                  <th>Folio</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="pago in pagos" :key="`${pago.id_local}-${pago.axo}-${pago.periodo}`">
                  <td><input type="checkbox" class="form-check-input" v-model="selected" :value="pago" /></td>
                  <td>{{ pago.id_local }}</td>
                  <td>{{ pago.datoslocal }}</td>
                  <td>{{ pago.axo }}</td>
                  <td>{{ pago.periodo }}</td>
                  <td>{{ pago.fecha_pago }}</td>
                  <td>{{ pago.oficina_pago }}</td>
                  <td>{{ pago.caja_pago }}</td>
                  <td>{{ pago.operacion_pago }}</td>
                  <td>{{ formatCurrency(pago.importe_pago) }}</td>
                  <td>{{ pago.folio }}</td>
                  <td>{{ pago.usuario }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No hay pagos para los criterios seleccionados</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Swal from 'sweetalert2';
import { useRouter } from 'vue-router';

const router = useRouter();

const loading = ref(false);
const form = ref({
  fecha: '',
  oficina: '',
  caja: '',
  operacion: ''
});
const oficinas = ref([]);
const pagos = ref([]);
const selected = ref([]);
const selectAll = ref(false);

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0);
};

const showToast = (type, message) => {
  Swal.fire({ toast: true, position: 'top-end', icon: type, title: message, showConfirmButton: false, timer: 3000 });
};async function cargarOficinas() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_captura_fecha_get_oficinas',
        Base: 'mercados',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      oficinas.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error cargando oficinas:', error);
  }
}

async function buscarPagos() {
  if (!form.value.fecha || !form.value.oficina || !form.value.caja || !form.value.operacion) {
    showToast('Complete todos los campos', 'warning');
    return;
  }

  loading.value = true;
  pagos.value = [];
  selected.value = [];
  selectAll.value = false;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_captura_fecha_get_pagos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_fecha', Valor: form.value.fecha, tipo: 'date' },
          { Nombre: 'p_oficina', Valor: form.value.oficina, tipo: 'integer' },
          { Nombre: 'p_caja', Valor: form.value.caja },
          { Nombre: 'p_operacion', Valor: form.value.operacion, tipo: 'integer' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      pagos.value = response.data.eResponse.data.result || [];
      if (pagos.value.length === 0) {
        showToast('No se encontraron pagos', 'info');
      }
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al buscar pagos', 'error');
  } finally {
    loading.value = false;
  }
}

function toggleAll() {
  if (selectAll.value) {
    selected.value = [...pagos.value];
  } else {
    selected.value = [];
  }
}

async function borrarPagos() {
  if (selected.value.length === 0) {
    showToast('Seleccione al menos un pago', 'warning');
    return;
  }

  const result = await Swal.fire({
    title: '¿Borrar pagos?',
    text: `Se eliminarán ${selected.value.length} pago(s) y se regenerarán los adeudos`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    confirmButtonText: 'Sí, borrar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  loading.value = true;
  let exitosos = 0;

  try {
    for (const pago of selected.value) {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_cons_captura_fecha_delete',
          Base: 'mercados',
          Parametros: [
            { Nombre: 'p_id_local', Valor: pago.id_local, tipo: 'integer' },
            { Nombre: 'p_axo', Valor: pago.axo, tipo: 'integer' },
            { Nombre: 'p_periodo', Valor: pago.periodo, tipo: 'integer' },
            { Nombre: 'p_usuario', Valor: 1, tipo: 'integer' }
          ]
        }
      });

      if (response.data?.eResponse?.success) {
        exitosos++;
      }
    }

    showToast(`${exitosos} pago(s) eliminado(s)`, 'success');
    buscarPagos();
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al borrar pagos', 'error');
  } finally {
    loading.value = false;
  }
}

onMounted(() => cargarOficinas());
</script>
