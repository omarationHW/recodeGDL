<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Captura Energía</h1>
        <p>Mercados - Detalle de Pagos Capturados de Energía</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-primary" @click="fetchData" :disabled="loading">
          <font-awesome-icon icon="sync" />
          Actualizar
        </button></div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos de Energía Capturados
            <span v-if="rows.length > 0" class="badge bg-primary ms-2">{{ rows.length }}</span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <div v-if="loading" class="text-center py-4">
            <div class="spinner-border text-primary" role="status"></div>
          </div>

          <div v-else-if="rows.length > 0" class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>ID</th>
                  <th>Datos Local</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Importe</th>
                  <th>Fecha Pago</th>
                  <th>Folio</th>
                  <th>Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in rows" :key="row.id_pago_energia">
                  <td>{{ row.id_pago_energia }}</td>
                  <td>{{ row.datoslocal }}</td>
                  <td>{{ row.axo }}</td>
                  <td>{{ row.periodo }}</td>
                  <td>{{ formatCurrency(row.importe_pago) }}</td>
                  <td>{{ row.fecha_pago }}</td>
                  <td>{{ row.folio }}</td>
                  <td>
                    <div class="button-group button-group-sm">
                      <button class="btn-municipal-danger btn-sm" @click="borrarPago(row)" title="Eliminar">
                        <font-awesome-icon icon="trash" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="text-center py-4 text-muted">
            <font-awesome-icon icon="inbox" size="3x" class="mb-3" />
            <p>No hay pagos registrados</p>
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
import { useRouter, useRoute } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';

const { showLoading, hideLoading } = useGlobalLoading();

const router = useRouter();
const route = useRoute();

const loading = ref(false);
const rows = ref([]);

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0);
};

const showToast = (type, message) => {
  Swal.fire({ toast: true, position: 'top-end', icon: type, title: message, showConfirmButton: false, timer: 3000 });
};async function fetchData() {
  showLoading('Cargando Captura de Energía', 'Consultando información...');
  loading.value = true;
  try {
    const idEnergia = route.query.id_energia || null;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_captura_energia_list',
        Base: 'mercados',
        Parametros: idEnergia ? [{ Nombre: 'p_id_energia', Valor: parseInt(idEnergia), tipo: 'integer' }] : []
      }
    });

    if (response.data?.eResponse?.success) {
      rows.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('Error al cargar datos', 'error');
  } finally {
    loading.value = false;
    hideLoading();
  }
}

async function borrarPago(row) {
  const result = await Swal.fire({
    title: '¿Eliminar pago?',
    text: 'Esta acción no se puede deshacer',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#d33',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  });

  if (!result.isConfirmed) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_captura_energia_delete',
        Base: 'mercados',
        Parametros: [{ Nombre: 'p_id_pago_energia', Valor: row.id_pago_energia, tipo: 'integer' }]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('Pago eliminado', 'success');
      fetchData();
    }
  } catch (error) {
    showToast('Error al eliminar', 'error');
  }
}

onMounted(() => fetchData());
</script>
