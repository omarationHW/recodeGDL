<template>
  <div class="detalle-pagos-diversos-page">
    <h2>Detalle de Pagos Diversos</h2>
    <div class="form-group">
      <label for="id_conv_resto">ID Convenio/Resto:</label>
      <input v-model="idConvResto" id="id_conv_resto" type="number" />
      <button @click="fetchPagos">Buscar</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="pagos.length">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Convenio</th>
            <th>Parcial</th>
            <th>Pago</th>
            <th>Fecha</th>
            <th>Rec</th>
            <th>Caja</th>
            <th>Oper.</th>
            <th>Folio Recibo</th>
            <th>Importe Pago</th>
            <th>Recargos</th>
            <th>Intereses</th>
            <th>Periodos</th>
            <th>Usuario</th>
            <th>Actualización</th>
            <th>Desgloce</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pagos" :key="p.id_conv_pago">
            <td>{{ p.datosConvenio || convenioString(p) }}</td>
            <td>{{ p.parcialidades || (p.pago_parcial + '-' + p.total_parciales) }}</td>
            <td>{{ p.descParcial || descParcial(p.cve_parcialidad) }}</td>
            <td>{{ formatDate(p.fecha_pago) }}</td>
            <td>{{ p.oficina_pago }}</td>
            <td>{{ p.caja_pago }}</td>
            <td>{{ p.operacion_pago }}</td>
            <td>{{ p.foliorecibo }}</td>
            <td>{{ money(p.importe_pago) }}</td>
            <td>{{ money(p.importe_recargo) }}</td>
            <td>{{ money(p.intereses) }}</td>
            <td>{{ periodosString(p) }}</td>
            <td>{{ p.usuario }}</td>
            <td>{{ formatDateTime(p.fecha_actual) }}</td>
            <td>
              <button @click="showDesgloce(p.id_adeudo)" v-if="p.id_adeudo">Ver</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="totals">
        <div><b>Total Pagado:</b> {{ money(totales.total_pagado) }}</div>
        <div><b>Total Recargos:</b> {{ money(totales.total_recargos) }}</div>
        <div><b>Total Intereses:</b> {{ money(totales.total_intereses) }}</div>
      </div>
    </div>
    <div v-if="showDesgloceModal">
      <div class="modal-overlay" @click="showDesgloceModal = false"></div>
      <div class="modal">
        <h4>Desgloce de Cuentas</h4>
        <table class="table table-sm">
          <thead>
            <tr>
              <th>Cuenta</th>
              <th>Descripción</th>
              <th>Importe</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="d in desgloce" :key="d.cuenta_apl">
              <td>{{ d.cuenta_apl }}</td>
              <td>{{ d.descripcion }}</td>
              <td>{{ money(d.importe) }}</td>
            </tr>
          </tbody>
        </table>
        <button @click="showDesgloceModal = false">Cerrar</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'DetallePagosDiversosPage',
  data() {
    return {
      idConvResto: '',
      pagos: [],
      totales: { total_pagado: 0, total_recargos: 0, total_intereses: 0 },
      loading: false,
      error: '',
      showDesgloceModal: false,
      desgloce: []
    };
  },
  methods: {
    async fetchPagos() {
      this.loading = true;
      this.error = '';
      this.pagos = [];
      this.totales = { total_pagado: 0, total_recargos: 0, total_intereses: 0 };
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getPagosDiversosDetalle',
          payload: { id_conv_resto: this.idConvResto }
        });
        if (res.data.status === 'success') {
          this.pagos = res.data.data;
          await this.fetchTotales();
        } else {
          this.error = res.data.message || 'Error al consultar pagos.';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      } finally {
        this.loading = false;
      }
    },
    async fetchTotales() {
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getResumenTotales',
          payload: { id_conv_resto: this.idConvResto }
        });
        if (res.data.status === 'success') {
          this.totales = res.data.data;
        }
      } catch (error) {
        // ignore
      }
    },
    async showDesgloce(id_adeudo) {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getDesgloceCuentas',
          payload: { id_adeudo }
        });
        if (res.data.status === 'success') {
          this.desgloce = res.data.data;
          this.showDesgloceModal = true;
        }
      } catch (error) {
        alert('Error al consultar desgloce: Error de conexión');
      } finally {
        this.loading = false;
      }
    },
    money(val) {
      if (val == null) return '$0.00';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    },
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString('es-MX');
    },
    formatDateTime(val) {
      if (!val) return '';
      return new Date(val).toLocaleString('es-MX');
    },
    convenioString(p) {
      // Simula lógica Delphi
      if (p.tipo === 14) {
        return `${p.manzana}-${p.lote}-${p.letra}`;
      } else {
        return `${p.letras_exp}-${p.numero_exp}-${p.axo_exp}`;
      }
    },
    descParcial(val) {
      if (val === 'I') return 'INICIAL';
      if (val === 'P') return 'PARCIAL';
      if (val === 'F') return 'FINAL';
      return '';
    },
    periodosString(p) {
      if (p.periodos) return p.periodos;
      if (p.mes_desde && p.axo_desde && p.mes_hasta && p.axo_hasta) {
        return `${p.mes_desde}/${p.axo_desde} - ${p.mes_hasta}/${p.axo_hasta}`;
      }
      return '';
    }
  }
};
</script>

<style scoped>
.detalle-pagos-diversos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
  text-align: left;
}
.totals {
  margin-top: 1rem;
  display: flex;
  gap: 2rem;
}
.loading { color: #888; }
.error { color: red; }
.modal-overlay {
  position: fixed; left:0; top:0; right:0; bottom:0; background: rgba(0,0,0,0.3); z-index: 1000;
}
.modal {
  position: fixed; left: 50%; top: 50%; transform: translate(-50%, -50%); background: #fff; padding: 2rem; z-index: 1001; border-radius: 8px; min-width: 400px;
}
</style>
