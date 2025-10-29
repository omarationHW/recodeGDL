<template>
  <div class="calculo-recargos-page">
    <h1>Cálculo de Recargos</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Cálculo de Recargos
    </div>
    <form @submit.prevent="onCalcular">
      <div class="form-section">
        <label>Contrato (ID Convenio):
          <input v-model="form.id_convenio" type="number" required @change="onContratoChange" />
        </label>
        <button type="button" @click="onContratoChange">Cargar Contrato</button>
      </div>
      <div v-if="contrato">
        <div class="form-section">
          <label>Pago Inicial:
            <input v-model.number="form.pago_inicial" type="number" :readonly="true" />
          </label>
          <label>Pago Quincenal:
            <input v-model.number="form.pago_quincenal" type="number" :readonly="true" />
          </label>
          <label>Pagos Parciales:
            <input v-model.number="form.pagos_parciales" type="number" :readonly="true" />
          </label>
          <label>Fecha Vencimiento:
            <input v-model="form.fecha_vencimiento" type="date" :readonly="true" />
          </label>
        </div>
        <div class="form-section">
          <label>
            <input type="radio" value="1" v-model="form.pago_inicial_activo" /> Pago Inicial
          </label>
          <label>
            <input type="radio" value="0" v-model="form.pago_inicial_activo" /> Sin Pago Inicial
          </label>
        </div>
        <div class="form-section">
          <label>
            <input type="radio" value="1" v-model="form.pago_parcial_activo" /> Pago Parcial
          </label>
          <label>
            <input type="radio" value="0" v-model="form.pago_parcial_activo" /> Sin Parcialidad
          </label>
          <label v-if="form.pago_parcial_activo == '1'">
            Parcialidades a Pagar:
            <input v-model.number="form.pagos_a_realizar" type="number" min="1" :max="form.pagos_parciales" />
          </label>
        </div>
        <div class="form-section">
          <button type="submit">Calcular Recargos</button>
        </div>
        <div v-if="resultado">
          <h3>Resultados</h3>
          <p>Importe a Pagar: <strong>${{ resultado.importe_a_pagar.toFixed(2) }}</strong></p>
          <p>Importe Recargos: <strong>${{ resultado.importerecargos.toFixed(2) }}</strong></p>
          <p>Porcentaje aplicado: <strong>{{ resultado.label_porc }}</strong></p>
        </div>
        <div v-if="error" class="error">{{ error }}</div>
      </div>
    </form>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'CalculoRecargosPage',
  data() {
    return {
      form: {
        id_convenio: '',
        pago_inicial: 0,
        pago_quincenal: 0,
        pagos_parciales: 0,
        fecha_vencimiento: '',
        pago_inicial_activo: '1',
        pago_parcial_activo: '1',
        pagos_a_realizar: 1
      },
      contrato: null,
      resultado: null,
      error: '',
      fecha_actual: '',
      requerimientos: [],
      porcentaje_recargos: 0,
      fechas: {}
    };
  },
  methods: {
    async onContratoChange() {
      this.error = '';
      this.resultado = null;
      if (!this.form.id_convenio) return;
      try {
        // Obtener datos del contrato
        const res = await axios.post('/api/execute', {
          action: 'getContrato',
          params: { id_convenio: this.form.id_convenio }
        });
        if (res.data.success && res.data.data) {
          this.contrato = res.data.data;
          this.form.pago_inicial = Number(this.contrato.pago_inicial);
          this.form.pago_quincenal = Number(this.contrato.pago_quincenal);
          this.form.pagos_parciales = Number(this.contrato.pagos_parciales);
          this.form.fecha_vencimiento = this.contrato.fecha_vencimiento;
          this.form.pagos_a_realizar = 1;
          // Obtener requerimientos
          const reqRes = await axios.post('/api/execute', {
            action: 'getRequerimientos',
            params: { id_convenio: this.form.id_convenio }
          });
          this.requerimientos = reqRes.data.data || [];
          // Obtener porcentaje de recargos
          const fechaV = new Date(this.contrato.fecha_vencimiento);
          const fechaA = new Date();
          this.fecha_actual = fechaA.toISOString().slice(0, 10);
          this.fechas = {
            alo: fechaA.getFullYear(),
            mes: fechaA.getMonth() + 1,
            dia: fechaA.getDate(),
            alov: fechaV.getFullYear(),
            mesv: fechaV.getMonth() + 1,
            diav: fechaV.getDate()
          };
          const recRes = await axios.post('/api/execute', {
            action: 'getRecargos',
            params: {
              ...this.fechas
            }
          });
          this.porcentaje_recargos = recRes.data.data ? Number(recRes.data.data.porcentaje) : 0;
        } else {
          this.error = 'Contrato no encontrado';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    },
    async onCalcular() {
      this.error = '';
      this.resultado = null;
      if (!this.contrato) {
        this.error = 'Debe cargar un contrato válido.';
        return;
      }
      let pag_inicio = this.form.pago_inicial_activo === '1' ? this.form.pago_inicial : 0;
      let pag_parcial = this.form.pago_parcial_activo === '1' ? (this.form.pago_quincenal * this.form.pagos_a_realizar) : 0;
      try {
        const res = await axios.post('/api/execute', {
          action: 'calcularRecargos',
          params: {
            id_convenio: this.form.id_convenio,
            pagos_parciales: this.form.pagos_parciales,
            pago_inicial: this.form.pago_inicial,
            pago_quincenal: this.form.pago_quincenal,
            pagos_a_realizar: this.form.pagos_a_realizar,
            pag_inicio,
            pag_parcial,
            fecha_vencimiento: this.form.fecha_vencimiento,
            fecha_actual: this.fecha_actual,
            ...this.fechas,
            requerimientos: this.requerimientos,
            porcentaje_recargos: this.porcentaje_recargos
          }
        });
        if (res.data.success) {
          this.resultado = res.data.data;
        } else {
          this.error = res.data.message || 'Error en el cálculo';
        }
      } catch (e) {
        this.error = e.response?.data?.message || e.message;
      }
    }
  }
};
</script>

<style scoped>
.calculo-recargos-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  font-size: 0.9em;
  margin-bottom: 1em;
}
.form-section {
  margin-bottom: 1.5em;
  display: flex;
  flex-wrap: wrap;
  gap: 1em;
}
label {
  display: flex;
  flex-direction: column;
  min-width: 180px;
}
.error {
  color: #b00;
  margin-top: 1em;
}
</style>
