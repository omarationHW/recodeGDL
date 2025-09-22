<template>
  <div class="predial-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Cobro de Predial</span>
    </nav>
    <h1>Cobro de Predial</h1>
    <form @submit.prevent="buscarCuenta">
      <div class="form-row">
        <label>Recaudadora</label>
        <input v-model="form.recaud" type="number" required style="width: 60px" />
        <label>Urb-Rus</label>
        <input v-model="form.urbrus" maxlength="1" required style="width: 30px" />
        <label>Cuenta</label>
        <input v-model="form.cuenta" type="number" required style="width: 100px" />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="cuenta">
      <h2>Datos del Contribuyente</h2>
      <div class="contribuyente-info">
        <div><strong>Nombre:</strong> {{ cuenta.ncompleto }}</div>
        <div><strong>Calle:</strong> {{ cuenta.calle }}</div>
        <div><strong>No. Exterior:</strong> {{ cuenta.noexterior }}</div>
        <div><strong>Interior:</strong> {{ cuenta.interior }}</div>
        <div><strong>Teléfono:</strong> {{ cuenta.telefono }}</div>
      </div>
      <h2>Detalle de Adeudos</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Desde</th>
            <th>Hasta</th>
            <th>Valor Fiscal</th>
            <th>Tasa</th>
            <th>ST</th>
            <th>Desc. Rec</th>
            <th>Rec a Pagar</th>
            <th>Desc. Imp</th>
            <th>Impto a Pagar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in liquidacion" :key="row.inicio">
            <td>{{ row.inicio }}</td>
            <td>{{ row.fin }}</td>
            <td>{{ row.valfiscal | currency }}</td>
            <td>{{ row.tasa }}</td>
            <td>{{ row.axosobre }}</td>
            <td>{{ row.recvir | currency }}</td>
            <td>{{ row.total | currency }}</td>
            <td>{{ row.impvir | currency }}</td>
            <td>{{ row.impade | currency }}</td>
          </tr>
        </tbody>
      </table>
      <h2>Totales</h2>
      <div class="totales-info">
        <div><strong>Impuesto:</strong> {{ totales.impppag | currency }}</div>
        <div><strong>Recargos:</strong> {{ totales.recppag | currency }}</div>
        <div><strong>Multa:</strong> {{ totales.multa | currency }}</div>
        <div><strong>Gastos:</strong> {{ totales.gasto | currency }}</div>
        <div><strong>Total a Pagar:</strong> {{ totalPagar | currency }}</div>
      </div>
      <div class="form-row">
        <label>Aportación Voluntaria</label>
        <input v-model.number="aportacionVoluntaria" type="number" min="0" step="1" style="width: 80px" />
        <input type="checkbox" v-model="cbAporta" /> Incluir
      </div>
      <div class="form-row">
        <label>Forma de Pago</label>
        <select v-model="formaPago">
          <option value="efectivo">Efectivo</option>
          <option value="cheque">Cheque</option>
          <option value="tarjeta">Tarjeta</option>
        </select>
      </div>
      <div v-if="formaPago==='cheque'">
        <div class="form-row">
          <label>Banco</label>
          <input v-model="cheque.banco" />
          <label>No. Cheque</label>
          <input v-model="cheque.numero" />
          <label>Importe Cheque</label>
          <input v-model.number="cheque.importe" type="number" />
        </div>
      </div>
      <div v-if="formaPago==='tarjeta'">
        <div class="form-row">
          <label>Banco</label>
          <input v-model="tarjeta.banco" />
          <label>No. Tarjeta</label>
          <input v-model="tarjeta.numero" />
          <label>Importe Tarjeta</label>
          <input v-model.number="tarjeta.importe" type="number" />
        </div>
      </div>
      <div class="form-row">
        <button @click="confirmarPago">Confirmar Pago</button>
        <button @click="liquidacionParcial">Liquidación Parcial</button>
        <button @click="pagoMinimo">Pago Mínimo</button>
        <button @click="pagoEspecial">Pago Especial</button>
        <button @click="imprimirRecibo">Imprimir Recibo</button>
      </div>
      <div v-if="mensaje" class="alert alert-info">{{ mensaje }}</div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'PredialPage',
  data() {
    return {
      form: {
        recaud: '',
        urbrus: '',
        cuenta: ''
      },
      cuenta: null,
      liquidacion: [],
      totales: {},
      totalPagar: 0,
      aportacionVoluntaria: 0,
      cbAporta: false,
      formaPago: 'efectivo',
      cheque: { banco: '', numero: '', importe: 0 },
      tarjeta: { banco: '', numero: '', importe: 0 },
      mensaje: ''
    }
  },
  watch: {
    cbAporta(val) {
      if (val) {
        this.aportacionVoluntaria = 25;
      } else {
        this.aportacionVoluntaria = 0;
      }
      this.calculaTotal();
    },
    aportacionVoluntaria() {
      this.calculaTotal();
    }
  },
  methods: {
    async buscarCuenta() {
      this.mensaje = '';
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'buscarCuenta',
            params: this.form
          }
        });
        if (data.eResponse.success && data.eResponse.data.length > 0) {
          this.cuenta = data.eResponse.data[0];
          await this.cargarLiquidacion();
        } else {
          this.mensaje = data.eResponse.message || 'Cuenta no encontrada';
        }
      } catch (e) {
        this.mensaje = e.message;
      }
    },
    async cargarLiquidacion() {
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'calcularLiquidacion',
            params: {
              cvecuenta: this.cuenta.cvecuenta,
              asal: 1900,
              bsal: 1,
              asalf: new Date().getFullYear(),
              bsalf: 6
            }
          }
        });
        this.liquidacion = data.eResponse.data;
        // Simular totales
        this.totales = {
          impppag: this.liquidacion.reduce((a, b) => a + (b.impade || 0), 0),
          recppag: this.liquidacion.reduce((a, b) => a + (b.total || 0), 0),
          multa: 0,
          gasto: 0
        };
        this.calculaTotal();
      } catch (e) {
        this.mensaje = e.message;
      }
    },
    calculaTotal() {
      let total = (this.totales.impppag || 0) + (this.totales.recppag || 0) + (this.totales.multa || 0) + (this.totales.gasto || 0) + (this.aportacionVoluntaria || 0);
      this.totalPagar = total;
    },
    async confirmarPago() {
      this.mensaje = '';
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'confirmarPago',
            params: {
              cvecuenta: this.cuenta.cvecuenta,
              usuario_id: 1, // Simulado
              forma_pago: this.formaPago,
              importe: this.totalPagar,
              detalle: this.liquidacion,
              aportacion_voluntaria: this.aportacionVoluntaria,
              diferencia: 0,
              cheque: this.formaPago === 'cheque' ? this.cheque : null,
              tarjeta: this.formaPago === 'tarjeta' ? this.tarjeta : null,
              pago_minimo: false,
              pago_especial: false
            }
          }
        });
        if (data.eResponse.success) {
          this.mensaje = 'Pago registrado correctamente';
        } else {
          this.mensaje = data.eResponse.message;
        }
      } catch (e) {
        this.mensaje = e.message;
      }
    },
    async liquidacionParcial() {
      this.mensaje = 'Funcionalidad de liquidación parcial no implementada en este demo.';
    },
    async pagoMinimo() {
      this.mensaje = 'Funcionalidad de pago mínimo no implementada en este demo.';
    },
    async pagoEspecial() {
      this.mensaje = 'Funcionalidad de pago especial no implementada en este demo.';
    },
    async imprimirRecibo() {
      this.mensaje = 'Funcionalidad de impresión de recibo no implementada en este demo.';
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
}
</script>

<style scoped>
.predial-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 1.5rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}
.contribuyente-info {
  background: #f8f8f8;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
}
.totales-info {
  background: #f0f0f0;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 4px;
}
.alert {
  margin-top: 1rem;
  color: #155724;
  background: #d4edda;
  border: 1px solid #c3e6cb;
  padding: 0.75rem 1.25rem;
  border-radius: 4px;
}
</style>
