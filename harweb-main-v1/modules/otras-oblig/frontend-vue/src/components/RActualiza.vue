<template>
  <div class="ractualiza-page">
    <h1>Actualización de Datos de Locales</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Actualiza Local</li>
      </ol>
    </nav>
    <form @submit.prevent="onBuscar">
      <div class="form-group">
        <label for="numero">Número de Local</label>
        <input v-model="form.numero" id="numero" maxlength="3" class="form-control" required />
      </div>
      <div class="form-group">
        <label for="letra">Letra</label>
        <input v-model="form.letra" id="letra" maxlength="1" class="form-control" />
      </div>
      <button type="submit" class="btn btn-primary">Buscar</button>
    </form>

    <div v-if="concesion" class="mt-4">
      <h3>Datos del Local</h3>
      <dl class="row">
        <dt class="col-sm-3">Concesionario</dt>
        <dd class="col-sm-9">{{ concesion.concesionario }}</dd>
        <dt class="col-sm-3">Ubicación</dt>
        <dd class="col-sm-9">{{ concesion.ubicacion }}</dd>
        <dt class="col-sm-3">Superficie</dt>
        <dd class="col-sm-9">{{ concesion.superficie }}</dd>
        <dt class="col-sm-3">Licencia</dt>
        <dd class="col-sm-9">{{ concesion.licencia }}</dd>
        <dt class="col-sm-3">Tipo de Local</dt>
        <dd class="col-sm-9">{{ concesion.unidades }}</dd>
        <dt class="col-sm-3">Inicio Obligación</dt>
        <dd class="col-sm-9">{{ concesion.fecha_inicio }}</dd>
      </dl>

      <div class="form-group">
        <label>Actualización a Realizar</label>
        <select v-model="form.opc" class="form-control">
          <option v-for="(op, idx) in opciones" :key="idx" :value="idx">{{ op }}</option>
        </select>
      </div>

      <div v-if="form.opc == 0" class="form-group">
        <label>Nuevo Concesionario</label>
        <input v-model="form.concesionario" class="form-control" />
      </div>
      <div v-if="form.opc == 1" class="form-group">
        <label>Nueva Ubicación</label>
        <input v-model="form.ubicacion" class="form-control" />
      </div>
      <div v-if="form.opc == 2" class="form-group">
        <label>Nueva Licencia</label>
        <input v-model="form.licencia" class="form-control" />
      </div>
      <div v-if="form.opc == 3" class="form-group">
        <label>Nueva Superficie</label>
        <input v-model="form.superficie" class="form-control" />
        <label>Año de Inicio</label>
        <input v-model="form.aso_ini" class="form-control" />
        <label>Mes de Inicio</label>
        <select v-model="form.mes_ini" class="form-control">
          <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
        </select>
      </div>
      <div v-if="form.opc == 4" class="form-group">
        <label>Nuevo Tipo de Local</label>
        <select v-model="form.descrip" class="form-control">
          <option value="INTERNO">INTERNO</option>
          <option value="EXTERNO">EXTERNO</option>
        </select>
        <label>Año de Inicio</label>
        <input v-model="form.aso_ini" class="form-control" />
        <label>Mes de Inicio</label>
        <select v-model="form.mes_ini" class="form-control">
          <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
        </select>
      </div>
      <div v-if="form.opc == 5" class="form-group">
        <label>Año de Inicio</label>
        <input v-model="form.aso_ini" class="form-control" />
        <label>Mes de Inicio</label>
        <select v-model="form.mes_ini" class="form-control">
          <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
        </select>
      </div>
      <button class="btn btn-success mt-3" @click="onActualizar">Aplicar Cambio</button>
      <button class="btn btn-secondary mt-3 ml-2" @click="reset">Salir</button>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'RActualizaPage',
  data() {
    return {
      form: {
        numero: '',
        letra: '',
        opc: 0,
        concesionario: '',
        ubicacion: '',
        licencia: '',
        superficie: '',
        descrip: '',
        aso_ini: '',
        mes_ini: '01'
      },
      concesion: null,
      error: '',
      success: '',
      opciones: [
        'Concesionario',
        'Ubicación',
        'Licencia',
        'Superficie',
        'Tipo de Local',
        'Inicio de Obligación'
      ],
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12']
    }
  },
  methods: {
    async onBuscar() {
      this.error = '';
      this.success = '';
      this.concesion = null;
      try {
        const control = this.form.numero + (this.form.letra ? '-' + this.form.letra : '');
        const res = await this.$axios.post('/api/execute', {
          action: 'buscar_concesion',
          params: { control }
        });
        if (res.data.data && res.data.data.length > 0) {
          this.concesion = res.data.data[0];
        } else {
          this.error = 'No existe LOCAL con este dato, intentalo de nuevo';
        }
      } catch (e) {
        this.error = e.response?.data?.error || 'Error en la búsqueda';
      }
    },
    async onActualizar() {
      this.error = '';
      this.success = '';
      if (!this.concesion) {
        this.error = 'Debe buscar un local primero.';
        return;
      }
      // Validaciones básicas
      if (this.form.opc == 0 && !this.form.concesionario) {
        this.error = 'Debe ingresar el nuevo concesionario.';
        return;
      }
      if (this.form.opc == 1 && !this.form.ubicacion) {
        this.error = 'Debe ingresar la nueva ubicación.';
        return;
      }
      if (this.form.opc == 2 && !this.form.licencia) {
        this.error = 'Debe ingresar la nueva licencia.';
        return;
      }
      if ((this.form.opc == 3 || this.form.opc == 4 || this.form.opc == 5) && (!this.form.aso_ini || !this.form.mes_ini)) {
        this.error = 'Debe indicar año y mes de inicio.';
        return;
      }
      // Verificar pagos si es necesario
      if ([3,4,5].includes(this.form.opc)) {
        try {
          const pagos = await this.$axios.post('/api/execute', {
            action: 'verificar_pagos',
            params: {
              id_datos: this.concesion.id_34_datos,
              periodo: `${this.form.aso_ini}-${this.form.mes_ini}`
            }
          });
          if (pagos.data.data && pagos.data.data.length > 0) {
            this.error = 'Existe pago(s) realizado(s) a partir de este periodo, intenta con otro';
            return;
          }
        } catch (e) {
          this.error = 'Error al verificar pagos';
          return;
        }
      }
      // Ejecutar actualización
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'actualizar_concesion',
          params: {
            opc: this.form.opc,
            id_34_datos: this.concesion.id_34_datos,
            concesionario: this.form.concesionario || this.concesion.concesionario,
            ubicacion: this.form.ubicacion || this.concesion.ubicacion,
            licencia: this.form.licencia || this.concesion.licencia,
            superficie: this.form.superficie || this.concesion.superficie,
            descrip: this.form.descrip || this.concesion.unidades,
            aso_ini: this.form.aso_ini || null,
            mes_ini: this.form.mes_ini || null
          }
        });
        if (res.data.data && res.data.data[0].resultado == 0) {
          this.success = 'Se ejecutó correctamente la actualización del Local/Concesión';
          this.reset();
        } else {
          this.error = res.data.data[0].mensaje || 'Error en la actualización';
        }
      } catch (e) {
        this.error = e.response?.data?.error || 'Error en la actualización';
      }
    },
    reset() {
      this.form = {
        numero: '',
        letra: '',
        opc: 0,
        concesionario: '',
        ubicacion: '',
        licencia: '',
        superficie: '',
        descrip: '',
        aso_ini: '',
        mes_ini: '01'
      };
      this.concesion = null;
      this.error = '';
      this.success = '';
    }
  }
}
</script>

<style scoped>
.ractualiza-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
