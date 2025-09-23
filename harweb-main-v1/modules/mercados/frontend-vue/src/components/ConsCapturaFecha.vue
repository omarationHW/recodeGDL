<template>
  <div class="cons-captura-fecha-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Consulta de Pagos Capturados por Mercado
    </div>
    <h2>Detalle de Pagos Capturados</h2>
    <form class="form-inline" @submit.prevent="buscarPagos">
      <label>Fecha Pago:
        <input type="date" v-model="form.fecha" required />
      </label>
      <label>Oficina:
        <select v-model="form.oficina" @change="cargarCajas" required>
          <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">{{ of.recaudadora }}</option>
        </select>
      </label>
      <label>Caja:
        <select v-model="form.caja" required>
          <option v-for="cj in cajas" :key="cj.caja" :value="cj.caja">{{ cj.caja }}</option>
        </select>
      </label>
      <label>Operación:
        <input type="number" v-model="form.operacion" required />
      </label>
      <button type="submit">Buscar</button>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="pagos.length">
      <table class="pagos-table">
        <thead>
          <tr>
            <th><input type="checkbox" v-model="selectAll" @change="toggleAll" /></th>
            <th>Control</th>
            <th>Datos Local</th>
            <th>Año</th>
            <th>Mes</th>
            <th>Fecha</th>
            <th>Rec</th>
            <th>Caja</th>
            <th>Oper.</th>
            <th>Renta</th>
            <th>Partida</th>
            <th>Actualización</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(pago, idx) in pagos" :key="pago.id_local + '-' + pago.axo + '-' + pago.periodo">
            <td><input type="checkbox" v-model="selected" :value="pago" /></td>
            <td>{{ pago.id_local }}</td>
            <td>{{ pago.datoslocal }}</td>
            <td>{{ pago.axo }}</td>
            <td>{{ pago.periodo }}</td>
            <td>{{ pago.fecha_pago | date }}</td>
            <td>{{ pago.oficina_pago }}</td>
            <td>{{ pago.caja_pago }}</td>
            <td>{{ pago.operacion_pago }}</td>
            <td>{{ pago.importe_pago | currency }}</td>
            <td>{{ pago.folio }}</td>
            <td>{{ pago.fecha_modificacion | datetime }}</td>
            <td>{{ pago.usuario }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="borrarPagos" :disabled="!selected.length">Borrar Pago(s)</button>
    </div>
    <div v-else-if="!loading">No hay pagos para los criterios seleccionados.</div>
  </div>
</template>

<script>
export default {
  name: 'ConsCapturaFechaPage',
  data() {
    return {
      form: {
        fecha: '',
        oficina: '',
        caja: '',
        operacion: ''
      },
      oficinas: [],
      cajas: [],
      pagos: [],
      selected: [],
      selectAll: false,
      loading: false,
      error: ''
    };
  },
  created() {
    this.cargarOficinas();
  },
  methods: {
    async cargarOficinas() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getOficinas' }
        });
        this.oficinas = res.data.eResponse.data;
      } catch (e) {
        this.error = 'Error cargando oficinas';
      } finally {
        this.loading = false;
      }
    },
    async cargarCajas() {
      if (!this.form.oficina) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getCajasByOficina', params: { oficina: this.form.oficina } }
        });
        this.cajas = res.data.eResponse.data;
      } catch (e) {
        this.error = 'Error cargando cajas';
      } finally {
        this.loading = false;
      }
    },
    async buscarPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      this.selected = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getPagosByFecha',
            params: {
              fecha: this.form.fecha,
              oficina: this.form.oficina,
              caja: this.form.caja,
              operacion: this.form.operacion
            }
          }
        });
        this.pagos = res.data.eResponse.data || [];
      } catch (e) {
        this.error = 'Error consultando pagos';
      } finally {
        this.loading = false;
      }
    },
    toggleAll() {
      if (this.selectAll) {
        this.selected = [...this.pagos];
      } else {
        this.selected = [];
      }
    },
    async borrarPagos() {
      if (!confirm('¿Está seguro de borrar los pagos seleccionados?')) return;
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'deletePagos',
            params: {
              pagos: this.selected,
              usuario: this.$store.state.usuario.id_usuario
            }
          }
        });
        this.buscarPagos();
      } catch (e) {
        this.error = 'Error borrando pagos';
      } finally {
        this.loading = false;
      }
    }
  },
  filters: {
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    datetime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString();
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.cons-captura-fecha-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.form-inline label {
  margin-right: 1rem;
}
.pagos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.pagos-table th, .pagos-table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
  text-align: left;
}
.pagos-table th {
  background: #f0f0f0;
}
.loading {
  color: #007bff;
  margin: 1rem 0;
}
.error {
  color: #c00;
  margin: 1rem 0;
}
</style>
