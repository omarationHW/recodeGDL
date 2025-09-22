<template>
  <div class="cons-captura-fecha-energia">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Consulta de Pagos Capturados de Energía Eléctrica
    </div>
    <h1>Detalle de Pagos Capturados de Energía Eléctrica</h1>
    <div class="form-row">
      <label>Fecha de Pago:</label>
      <input type="date" v-model="filters.fecha_pago" />
      <label>Oficina:</label>
      <select v-model="filters.oficina_pago">
        <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">{{ of.id_rec }} - {{ of.recaudadora }}</option>
      </select>
      <label>Caja:</label>
      <select v-model="filters.caja_pago">
        <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
      </select>
      <label>Operación:</label>
      <input type="number" v-model="filters.operacion_pago" />
      <button @click="buscarPagos">Buscar</button>
    </div>
    <div class="table-responsive">
      <table class="table table-striped">
        <thead>
          <tr>
            <th><input type="checkbox" v-model="selectAll" @change="toggleSelectAll" /></th>
            <th>Control</th>
            <th>Datos Local</th>
            <th>Año</th>
            <th>Mes</th>
            <th>Fecha</th>
            <th>Rec</th>
            <th>Caja</th>
            <th>Oper.</th>
            <th>Cuota Energía</th>
            <th>Partida</th>
            <th>Actualización</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="pago in pagos" :key="pago.id_pago_energia">
            <td><input type="checkbox" v-model="selected" :value="pago.id_pago_energia" /></td>
            <td>{{ pago.id_energia }}</td>
            <td>{{ pago.datoslocal }}</td>
            <td>{{ pago.axo }}</td>
            <td>{{ pago.periodo }}</td>
            <td>{{ pago.fecha_pago }}</td>
            <td>{{ pago.oficina_pago }}</td>
            <td>{{ pago.caja_pago }}</td>
            <td>{{ pago.operacion_pago }}</td>
            <td>{{ pago.importe_pago }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ pago.fecha_modificacion }}</td>
            <td>{{ pago.usuario }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="actions">
      <button @click="borrarPagos" :disabled="selected.length === 0">Borrar Pago(s)</button>
      <button @click="$router.push('/')">Salir</button>
    </div>
    <div v-if="message" class="alert" :class="{'alert-success': success, 'alert-danger': !success}">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsCapturaFechaEnergia',
  data() {
    return {
      filters: {
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      },
      oficinas: [],
      cajas: [],
      pagos: [],
      selected: [],
      selectAll: false,
      message: '',
      success: true
    };
  },
  watch: {
    'filters.oficina_pago'(val) {
      this.loadCajas();
    }
  },
  created() {
    this.loadOficinas();
  },
  methods: {
    async loadOficinas() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getOficinas' })
      });
      const data = await res.json();
      if (data.success) this.oficinas = data.data;
    },
    async loadCajas() {
      if (!this.filters.oficina_pago) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCajasByOficina', params: { oficina: this.filters.oficina_pago } })
      });
      const data = await res.json();
      if (data.success) this.cajas = data.data;
    },
    async buscarPagos() {
      this.message = '';
      this.success = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'getPagosByFecha',
          params: this.filters
        })
      });
      const data = await res.json();
      if (data.success) {
        this.pagos = data.data;
        this.selected = [];
        this.selectAll = false;
      } else {
        this.message = data.message || 'Error al buscar pagos';
        this.success = false;
      }
    },
    toggleSelectAll() {
      if (this.selectAll) {
        this.selected = this.pagos.map(p => p.id_pago_energia);
      } else {
        this.selected = [];
      }
    },
    async borrarPagos() {
      if (!confirm('¿Está seguro de borrar los pagos seleccionados?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'deletePagosEnergia',
          params: {
            pagos_ids: this.selected,
            fecha_pago: this.filters.fecha_pago,
            oficina_pago: this.filters.oficina_pago,
            operacion_pago: this.filters.operacion_pago
          }
        })
      });
      const data = await res.json();
      if (data.success) {
        this.message = 'Pago(s) eliminado(s) correctamente';
        this.success = true;
        this.buscarPagos();
      } else {
        this.message = data.message || 'Error al borrar pagos';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
.cons-captura-fecha-energia {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.table-responsive {
  overflow-x: auto;
}
.actions {
  margin-top: 1rem;
  display: flex;
  gap: 1rem;
}
.alert {
  margin-top: 1rem;
  padding: 0.75rem 1rem;
  border-radius: 4px;
}
.alert-success {
  background: #e6ffed;
  color: #1a7f37;
}
.alert-danger {
  background: #ffeaea;
  color: #a94442;
}
</style>
