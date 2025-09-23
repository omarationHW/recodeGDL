<template>
  <div class="desc-multampal-page">
    <h1>Descuentos a Multas Municipales</h1>
    <form @submit.prevent="onBuscarMulta">
      <div class="form-row">
        <label>Dependencia:</label>
        <select v-model="form.id_dependencia" required>
          <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">{{ dep.descripcion }}</option>
        </select>
      </div>
      <div class="form-row">
        <label>Año del Acta:</label>
        <input type="number" v-model="form.axo_acta" required min="1900" />
      </div>
      <div class="form-row">
        <label>Número de Acta:</label>
        <input type="number" v-model="form.num_acta" required min="1" />
      </div>
      <button type="submit">Buscar Multa</button>
    </form>

    <div v-if="multa">
      <h2>Datos de la Multa</h2>
      <div class="info-row"><strong>Contribuyente:</strong> {{ multa.contribuyente }}</div>
      <div class="info-row"><strong>Domicilio:</strong> {{ multa.domicilio }}</div>
      <div class="info-row"><strong>Calificación:</strong> {{ multa.calificacion }}</div>
      <div class="info-row"><strong>Multa a pagar:</strong> {{ multa.multa }}</div>
      <div class="info-row"><strong>Estado:</strong> {{ multa.estado }}</div>
    </div>

    <div v-if="multa">
      <h2>Descuento</h2>
      <form @submit.prevent="onGuardarDescuento">
        <div class="form-row">
          <label>Tipo de descuento:</label>
          <select v-model="descuento.tipo_descto" required>
            <option value="P">Porcentaje</option>
            <option value="I">Importe</option>
          </select>
        </div>
        <div class="form-row">
          <label v-if="descuento.tipo_descto==='P'">Porcentaje a descontar:</label>
          <label v-else>Importe a descontar:</label>
          <input v-if="descuento.tipo_descto==='P'" type="number" v-model.number="descuento.valor" min="1" max="100" required />
          <input v-else type="number" v-model.number="descuento.valor" min="1" :max="multa.calificacion" required />
        </div>
        <div class="form-row">
          <label>Autoriza:</label>
          <select v-model="descuento.autoriza" required>
            <option v-for="aut in autorizadores" :key="aut.cveautoriza" :value="aut.cveautoriza">
              {{ aut.descripcion }} (Tope: {{ aut.porcentajetope }}%)
            </option>
          </select>
        </div>
        <div class="form-row">
          <label>Observación:</label>
          <textarea v-model="descuento.observacion"></textarea>
        </div>
        <div class="form-row">
          <button type="submit">{{ descuento.id_descmultampal ? 'Modificar' : 'Agregar' }} Descuento</button>
          <button v-if="descuento.id_descmultampal" @click.prevent="onCancelarDescuento">Cancelar Descuento</button>
        </div>
      </form>
    </div>

    <div v-if="alert" class="alert">{{ alert }}</div>
  </div>
</template>

<script>
export default {
  name: 'DescMultampalPage',
  data() {
    return {
      form: {
        id_dependencia: '',
        axo_acta: '',
        num_acta: ''
      },
      multa: null,
      descuento: {
        id_descmultampal: null,
        tipo_descto: 'P',
        valor: '',
        autoriza: '',
        observacion: ''
      },
      dependencias: [],
      autorizadores: [],
      alert: ''
    }
  },
  created() {
    this.fetchDependencias();
    this.fetchAutorizadores();
  },
  methods: {
    async fetchDependencias() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarDependencias' })
      });
      const json = await res.json();
      if (json.success) this.dependencias = json.data;
    },
    async fetchAutorizadores() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'listarAutorizadores' })
      });
      const json = await res.json();
      if (json.success) this.autorizadores = json.data;
    },
    async onBuscarMulta() {
      this.alert = '';
      this.multa = null;
      this.descuento = {
        id_descmultampal: null,
        tipo_descto: 'P',
        valor: '',
        autoriza: '',
        observacion: ''
      };
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscarMulta',
            params: {
              id_dependencia: this.form.id_dependencia,
              axo_acta: this.form.axo_acta,
              num_acta: this.form.num_acta
            }
          })
        });
        const json = await res.json();
        if (!json.success) throw new Error(json.message);
        this.multa = json.data;
        // Buscar descuento vigente
        const res2 = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'consultarDescuento',
            params: { id_multa: this.multa.id_multa }
          })
        });
        const json2 = await res2.json();
        if (json2.success && json2.data) {
          this.descuento = {
            id_descmultampal: json2.data.id_descmultampal,
            tipo_descto: json2.data.tipo_descto,
            valor: json2.data.valor,
            autoriza: json2.data.autoriza,
            observacion: json2.data.observacion
          };
        }
      } catch (e) {
        this.alert = e.message;
      }
    },
    async onGuardarDescuento() {
      this.alert = '';
      try {
        let action = this.descuento.id_descmultampal ? 'editarDescuento' : 'agregarDescuento';
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action,
            params: {
              id_descmultampal: this.descuento.id_descmultampal,
              id_multa: this.multa.id_multa,
              tipo_descto: this.descuento.tipo_descto,
              valor: this.descuento.valor,
              autoriza: this.descuento.autoriza,
              observacion: this.descuento.observacion
            }
          })
        });
        const json = await res.json();
        if (!json.success) throw new Error(json.message);
        this.alert = 'Descuento guardado correctamente';
        this.onBuscarMulta();
      } catch (e) {
        this.alert = e.message;
      }
    },
    async onCancelarDescuento() {
      this.alert = '';
      if (!this.descuento.id_descmultampal) return;
      if (!confirm('¿Está seguro de cancelar el descuento?')) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'cancelarDescuento',
            params: {
              id_descmultampal: this.descuento.id_descmultampal,
              motivo: this.descuento.observacion
            }
          })
        });
        const json = await res.json();
        if (!json.success) throw new Error(json.message);
        this.alert = 'Descuento cancelado correctamente';
        this.onBuscarMulta();
      } catch (e) {
        this.alert = e.message;
      }
    }
  }
}
</script>

<style scoped>
.desc-multampal-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.form-row {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
}
.form-row label {
  width: 180px;
  font-weight: bold;
}
.form-row input, .form-row select, .form-row textarea {
  flex: 1;
  padding: 0.5rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.info-row {
  margin-bottom: 0.5rem;
}
.alert {
  background: #ffe0e0;
  color: #a00;
  padding: 1rem;
  border-radius: 4px;
  margin-top: 1rem;
}
</style>
