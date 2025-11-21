<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="store" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Captura por Mercado</h1>
        <p>Mercados - Detalle de Pagos Capturados por Mercado</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-danger" @click="cerrar">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Selección de Mercado -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Seleccionar Mercado
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-6 mb-3">
              <label class="form-label">Mercado *</label>
              <select class="form-select" v-model="selectedMercado" @change="buscarPagos">
                <option value="">Seleccione un mercado...</option>
                <option v-for="m in mercados" :key="m.id_mercado" :value="m">
                  {{ m.oficina }}-{{ m.num_mercado }} | {{ m.nombre_mercado }}
                </option>
              </select>
            </div>
            <div class="col-md-6 mb-3" v-if="selectedMercado">
              <label class="form-label">Información</label>
              <div class="p-2 bg-light rounded">
                <strong>Oficina:</strong> {{ selectedMercado.oficina }} |
                <strong>Mercado:</strong> {{ selectedMercado.num_mercado }}
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Resultados -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Pagos Capturados
            <span v-if="pagos.length > 0" class="badge bg-primary ms-2">{{ pagos.length }}</span>
          </h5>
          <button v-if="pagos.length > 0" class="btn btn-sm btn-primary ms-auto" @click="buscarPagos">
            <font-awesome-icon icon="sync" />
            Actualizar
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
                  <th>ID</th>
                  <th>Datos Local</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th>Fecha Pago</th>
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
            <p v-if="selectedMercado">No hay pagos registrados para este mercado</p>
            <p v-else>Seleccione un mercado para ver los pagos</p>
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
const mercados = ref([]);
const selectedMercado = ref(null);
const pagos = ref([]);

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value || 0);
};

const showToast = (type, message) => {
  Swal.fire({ toast: true, position: 'top-end', icon: type, title: message, showConfirmButton: false, timer: 3000 });
};

const cerrar = () => router.push('/mercados');

async function cargarMercados() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_captura_merc_get_mercados',
        Base: 'mercados',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      mercados.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error cargando mercados:', error);
    showToast('error', 'Error al cargar mercados');
  }
}

async function buscarPagos() {
  if (!selectedMercado.value) {
    pagos.value = [];
    return;
  }

  loading.value = true;
  pagos.value = [];

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_cons_captura_merc_get_pagos',
        Base: 'mercados',
        Parametros: [
          { Nombre: 'p_oficina', Valor: selectedMercado.value.oficina, tipo: 'integer' },
          { Nombre: 'p_num_mercado', Valor: selectedMercado.value.num_mercado, tipo: 'integer' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      pagos.value = response.data.eResponse.data.result || [];
      if (pagos.value.length === 0) {
        showToast('info', 'No se encontraron pagos');
      }
    }
  } catch (error) {
    console.error('Error:', error);
    showToast('error', 'Error al buscar pagos');
  } finally {
    loading.value = false;
  }
}

onMounted(() => cargarMercados());
</script>
