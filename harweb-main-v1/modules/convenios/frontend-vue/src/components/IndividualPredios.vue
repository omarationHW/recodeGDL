<template>
  <div class="individual-predios-page">
    <h2>Consulta Individual del Convenio Seleccionado</h2>
    <div class="predio-info">
      <h3>Datos del Convenio</h3>
      <div v-if="predio">
        <div><strong>Control:</strong> {{ predio.id_conv_predio }}</div>
        <div><strong>Tipo:</strong> {{ predio.tipo }}</div>
        <div><strong>Subtipo:</strong> {{ predio.subtipo }}</div>
        <div><strong>Manzana:</strong> {{ predio.manzana }}</div>
        <div><strong>Lote:</strong> {{ predio.lote }}</div>
        <div><strong>Letra:</strong> {{ predio.letra }}</div>
        <div><strong>Nombre:</strong> {{ predio.nombre }}</div>
        <div><strong>Calle:</strong> {{ predio.calle }}</div>
        <div><strong>Num. Exterior:</strong> {{ predio.num_exterior }}</div>
        <div><strong>Num. Interior:</strong> {{ predio.num_interior }}</div>
        <div><strong>Inciso:</strong> {{ predio.inciso }}</div>
        <div><strong>Fecha Inicio:</strong> {{ predio.fecha_inicio }}</div>
        <div><strong>Fecha Vencimiento:</strong> {{ predio.fecha_venc }}</div>
        <div><strong>Cantidad Total:</strong> {{ predio.cantidad_total | currency }}</div>
        <div><strong>Cantidad Inicial:</strong> {{ predio.cantidad_inicio | currency }}</div>
        <div><strong>Pago Parcial:</strong> {{ predio.pago_parcial | currency }}</div>
        <div><strong>Pago Final:</strong> {{ predio.pago_final | currency }}</div>
        <div><strong>Total Pagos:</strong> {{ predio.total_pagos }}</div>
        <div><strong>Metros:</strong> {{ predio.metros }}</div>
        <div><strong>Tipo Pago:</strong> {{ predio.tipo_pago }}</div>
        <div><strong>Vigencia:</strong> {{ predio.vigencia }}</div>
        <div><strong>Usuario:</strong> {{ predio.usuario }}</div>
        <div><strong>Observaciones:</strong> {{ predio.observaciones }}</div>
      </div>
      <div v-else>
        <em>Seleccione un convenio para ver los detalles.</em>
      </div>
    </div>

    <div class="estado-cuenta" v-if="predio">
      <h3>Estado de Cuenta</h3>
      <div class="estado-cuenta-totales">
        <div><strong>Total Pagado:</strong> {{ totPagado | currency }}</div>
        <div><strong>Adeudo Vencido:</strong> {{ adeudosTotal | currency }}</div>
        <div><strong>Recargos:</strong> {{ recargosTotal | currency }}</div>
        <div><strong>Total Vencido:</strong> {{ totalVencido | currency }}</div>
      </div>
      <h4>Parcialidades Vencidas</h4>
      <table class="table table-sm table-bordered">
        <thead>
          <tr>
            <th>Parc. Ade</th>
            <th>Importe</th>
            <th>Fecha Venc.</th>
            <th>Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="adeudo in adeudos" :key="adeudo.pago_parcial">
            <td>{{ adeudo.pago_parcial }}</td>
            <td>{{ adeudo.importe | currency }}</td>
            <td>{{ adeudo.fecha_venc }}</td>
            <td>{{ adeudo.recargos | currency }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="actions" v-if="predio">
      <button @click="verDetallePagos" class="btn btn-primary">Detalle Pagos</button>
      <button @click="goBack" class="btn btn-secondary">Salir</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'IndividualPrediosPage',
  props: {
    id_conv_predio: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      predio: null,
      adeudos: [],
      totPagado: 0,
      adeudosTotal: 0,
      recargosTotal: 0,
      totalVencido: 0
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString(undefined, { minimumFractionDigits: 2 });
    }
  },
  methods: {
    async fetchPredio() {
      const res = await axios.post('/api/execute', {
        eRequest: {
          action: 'getPredioById',
          params: { id_conv_predio: this.id_conv_predio }
        }
      });
      if (res.data.eResponse.success) {
        this.predio = res.data.eResponse.data;
      }
    },
    async fetchAdeudos() {
      if (!this.predio) return;
      const res = await axios.post('/api/execute', {
        eRequest: {
          action: 'getAdeudosByPredio',
          params: {
            id_conv_resto: this.predio.id_conv_resto,
            fecha: new Date().toISOString().slice(0, 10)
          }
        }
      });
      if (res.data.eResponse.success) {
        this.adeudos = res.data.eResponse.data;
        this.adeudosTotal = 0;
        this.recargosTotal = 0;
        for (let a of this.adeudos) {
          this.adeudosTotal += Number(a.importe);
          this.recargosTotal += Number(a.recargos);
        }
        this.totalVencido = this.adeudosTotal + this.recargosTotal;
      }
    },
    async fetchTotPagado() {
      if (!this.predio) return;
      const res = await axios.post('/api/execute', {
        eRequest: {
          action: 'getTotPagadoByPredio',
          params: { id_conv_resto: this.predio.id_conv_resto }
        }
      });
      if (res.data.eResponse.success) {
        let total = 0;
        for (let p of res.data.eResponse.data) {
          total += Number(p.importe_pago);
        }
        this.totPagado = total;
      }
    },
    async loadAll() {
      await this.fetchPredio();
      await this.fetchAdeudos();
      await this.fetchTotPagado();
    },
    verDetallePagos() {
      // Redirigir a la página de detalle de pagos (debe existir la ruta)
      this.$router.push({ name: 'DetallePagosConvPred', params: { id_conv_resto: this.predio.id_conv_resto } });
    },
    goBack() {
      this.$router.back();
    }
  },
  mounted() {
    this.loadAll();
  }
};
</script>

<style scoped>
.individual-predios-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.predio-info, .estado-cuenta {
  background: #f9f9f9;
  border-radius: 8px;
  padding: 1rem 2rem;
  margin-bottom: 2rem;
}
.estado-cuenta-totales {
  display: flex;
  gap: 2rem;
  margin-bottom: 1rem;
}
.actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}
</style>
